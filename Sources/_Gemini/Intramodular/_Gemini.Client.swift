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
            throw FileProcessingError.invalidFileName
        }
        
        for attempt in 1...maxAttempts {
            do {
                let input = _Gemini.APISpecification.RequestBodies.FileStatusInput(name: name)
                let fileStatus = try await run(\.getFile, with: input)
                
                print("File status attempt \(attempt): \(fileStatus.state)")
                
                switch fileStatus.state {
                case .active:
                    return fileStatus
                case .processing:
                    break
                }
                
                if attempt < maxAttempts {
                    try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                }
            } catch {
                if attempt == maxAttempts {
                    throw error
                }
                continue
            }
        }
        
        throw FileProcessingError.processingTimeout(fileName: name)
    }
    
    public func generateContent(
        url: URL,
        type: HTTPMediaType,
        prompt: String,
        model: _Gemini.Model
    ) async throws -> _Gemini.APISpecification.ResponseBodies.GenerateContent {
        do {
            let data = try Data(contentsOf: url)
            
            let uploadedFile = try await uploadFile(
                fileData: data,
                mimeType: type,
                displayName: "Test"
            )
            
            return try await self.generateContent(
                file: uploadedFile,
                prompt: prompt,
                model: model
            )
        } catch let error as NSError where error.domain == NSCocoaErrorDomain {
            throw _Gemini.APIError.unknown(message: "Failed to read file: \(error.localizedDescription)")
        } catch {
            throw error
        }
    }
    
    public func generateContent(
        file: _Gemini.File,
        prompt: String,
        model: _Gemini.Model
    ) async throws -> _Gemini.APISpecification.ResponseBodies.GenerateContent {
        guard let fileName = file.name else {
            throw FileProcessingError.invalidFileName
        }
        
        do {
            print("Waiting for file processing...")
            let processedFile = try await waitForFileProcessing(name: fileName)
            print("File processing complete: \(processedFile)")
            
            guard let mimeType = file.mimeType else {
                throw _Gemini.APIError.unknown(message: "Invalid MIME type")
            }
            
            let fileUri = processedFile.uri
            
            let fileContent = _Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [
                    .file(url: fileUri, mimeType: mimeType),
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
            
            print(input)
            
            return try await run(\.generateContent, with: input)
        } catch let error as FileProcessingError {
            throw error
        } catch {
            throw _Gemini.APIError.unknown(message: "Content generation failed: \(error.localizedDescription)")
        }
    }
    
    public func uploadFile(
        fileData: Data,
        mimeType: HTTPMediaType,
        displayName: String
    ) async throws -> _Gemini.File {
        guard !displayName.isEmpty else {
            throw FileProcessingError.invalidFileName
        }
        
        do {
            let input = _Gemini.APISpecification.RequestBodies.FileUploadInput(
                fileData: fileData,
                mimeType: mimeType.rawValue,
                displayName: displayName
            )
            
            let response = try await run(\.uploadFile, with: input)
            return response.file
        } catch {
            throw _Gemini.APIError.unknown(message: "File upload failed: \(error.localizedDescription)")
        }
    }
    
    public func getFile(
        name: String
    ) async throws -> _Gemini.File {
        guard !name.isEmpty else {
            throw FileProcessingError.invalidFileName
        }
        
        do {
            let input = _Gemini.APISpecification.RequestBodies.FileStatusInput(name: name)
            return try await run(\.getFile, with: input)
        } catch {
            throw _Gemini.APIError.unknown(message: "Failed to get file status: \(error.localizedDescription)")
        }
    }
    
    public func deleteFile(
        fileURL: URL
    ) async throws {
        do {
            let input = _Gemini.APISpecification.RequestBodies.DeleteFileInput(fileURL: fileURL)
            try await run(\.deleteFile, with: input)
        } catch {
            throw _Gemini.APIError.unknown(message: "Failed to delete file: \(error.localizedDescription)")
        }
    }
}

// Error Handling

fileprivate enum FileProcessingError: Error {
    case invalidFileName
    case processingTimeout(fileName: String)
    case invalidFileState(state: String)
    case fileNotFound(name: String)
}
