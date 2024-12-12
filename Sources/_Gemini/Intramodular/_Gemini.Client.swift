//
//  _Gemini.CLient.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Foundation
import SwiftAPI
import Merge
import FoundationX
import Swallow

extension _Gemini {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public typealias API = _Gemini.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(configuration: API.Configuration) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(apiKey: String?) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension _Gemini.Client {
    private func waitForFileProcessing(
        name: String,
        maxAttempts: Int = 10,
        delaySeconds: Double = 1.0
    ) async throws -> _Gemini.File {
        guard !name.isEmpty else {
            throw _Gemini.APIError.unknown(message: "Invalid file name")
        }
        
        for attempt in 1...maxAttempts {
            let input = _Gemini.APISpecification.RequestBodies.FileStatusInput(name: name)
            let fileStatus = try await run(\.getFile, with: input)
            
            print("File status attempt \(attempt): \(fileStatus.state)")
            
            if fileStatus.state == .active {
                return fileStatus
            }
            
            if attempt < maxAttempts {
                try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
            }
        }
        
        throw _Gemini.APIError.unknown(message: "File processing timeout")
    }
    
    public func generateContent(
        data: Data,
        type: HTTPMediaType,
        prompt: String,
        model: _Gemini.Model
    ) async throws -> _Gemini.APISpecification.ResponseBodies.GenerateContent {
        print("Uploading file with MIME type: \(type.rawValue)")
        
        let uploadedFile = try await uploadFile(
            fileData: data,
            mimeType: type,
            displayName: "Test"
        )
        
        print("Uploaded file response: \(uploadedFile)")
        
        guard let fileName = uploadedFile.name else {
            throw _Gemini.APIError.unknown(message: "File name missing from upload response")
        }
        
        do {
            
            print("Waiting for file processing...")
            let processedFile = try await waitForFileProcessing(name: fileName)
            print("File processing complete: \(processedFile)")
            
            // Create content request matching the expected format
            let fileContent = _Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [
                    .file(url: processedFile.uri, mimeType: type.rawValue),
                ]
            )
            
            let promptContent = _Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [
                    .text(prompt)
                ]
            )
            
            let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
                model: model,
                requestBody: .init(
                    contents: [fileContent, promptContent],
                    generationConfig: .init(
                        maxOutputTokens: 8192,
                        temperature: 1,
                        topP: 0.95,
                        topK: 40,
                        responseMimeType: "text/plain"
                    )
                )
            )
            
            return try await run(\.generateContent, with: input)
        } catch {
            throw error
        }
    }
    
    public func uploadFile(
        fileData: Data,
        mimeType: HTTPMediaType,
        displayName: String
    ) async throws -> _Gemini.File {
        let input = _Gemini.APISpecification.RequestBodies.FileUploadInput(
            fileData: fileData,
            mimeType: mimeType.rawValue,
            displayName: displayName
        )
        
        let response = try await run(\.uploadFile, with: input)
        return response.file
    }
    
    public func getFile(
        name: String
    ) async throws -> _Gemini.File {
        let input = _Gemini.APISpecification.RequestBodies.FileStatusInput(name: name)
        let file = try await run(\.getFile, with: input)
        return file
    }
    
    public func deleteFile(
        fileURL: URL
    ) async throws {
        let input = _Gemini.APISpecification.RequestBodies.DeleteFileInput(fileURL: fileURL)
        try await run(\.deleteFile, with: input)
    }
}
