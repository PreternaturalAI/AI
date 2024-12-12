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
        for attempt in 1...maxAttempts {
            let input = _Gemini.APISpecification.RequestBodies.FileStatusInput(name: name)
            let fileStatus = try await run(\.getFileStatus, with: input)
            
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
        type: _MediaAssetFileType,
        prompt: String
    ) async throws -> _Gemini.APISpecification.ResponseBodies.GenerateContent {
        print("Uploading file with MIME type: \(type.mimeType)")
        
        // Upload file
        let uploadedFile = try await uploadFile(
            fileData: data,
            mimeType: type.mimeType,
            displayName: "\(UUID().uuidString).\(type.fileExtension)"
        )
        
        print("Uploaded file response: \(uploadedFile)")
        
        do {
            // Wait for file processing to complete
            print("Waiting for file processing...")
            let processedFile = try await waitForFileProcessing(name: uploadedFile.name ?? "")
            print("File processing complete: \(processedFile)")
            
            // Create the file content
            let fileContent = _Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [
                    .file(url: processedFile.uri, mimeType: type.mimeType)
                ]
            )
            
            let promptContent = _Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [.text(prompt)]
            )
            
            let speechRequest = _Gemini.APISpecification.RequestBodies.SpeechRequest(
                contents: [fileContent, promptContent],
                generationConfig: .init(
                    maxOutputTokens: 8192,
                    temperature: 1.0,
                    topP: 0.95,
                    topK: 40,
                    responseMimeType: "text/plain"
                )
            )
            
            let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
                model: .gemini_1_5_flash,
                requestBody: speechRequest
            )
            
            return try await run(\.generateContent, with: input)
        } catch {
            // Ensure we try to delete the file even if processing fails
//            try? await deleteFile(fileURL: uploadedFile.uri)
            throw error
        }
    }
    
    public func deleteFile(
        fileURL: URL
    ) async throws {
        let input = _Gemini.APISpecification.RequestBodies.DeleteFileInput(fileURL: fileURL)
        try await run(\.deleteFile, with: input)
    }
    
    public func uploadFile(
        fileData: Data,
        mimeType: String,
        displayName: String
    ) async throws -> _Gemini.File {
        let input = _Gemini.APISpecification.RequestBodies.FileUploadInput(
            fileData: fileData,
            mimeType: mimeType,
            displayName: displayName
        )
        
        let response = try await run(\.uploadFile, with: input)
        return response.file
    }
}
