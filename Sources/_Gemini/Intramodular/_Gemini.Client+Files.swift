//
//  _Gemini.Client+Files.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Foundation
import NetworkKit

extension _Gemini.Client {
    internal func handleFileGeneration(
        fileSource: FileSource,
        mimeType: HTTPMediaType?,
        messages: [_Gemini.Message],
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig
    ) async throws -> _Gemini.Content {
        let initialFile: _Gemini.File
        
        switch fileSource {
            case .localFile(let fileURL):
                initialFile = try await processLocalFile(
                    fileURL: fileURL,
                    mimeType: mimeType
                )
                
            case .remoteURL(let url):
                initialFile = try await processRemoteURL(
                    url: url,
                    mimeType: mimeType
                )
                
            case .uploadedFile(let file):
                initialFile = file
        }
        
        let processedFile = try await waitForFileProcessing(name: initialFile.name ?? "")
        
        return try await generateWithFile(
            file: processedFile,
            messages: messages,
            model: model,
            config: config
        )
    }
    
    internal func processLocalFile(
        fileURL: URL,
        mimeType: HTTPMediaType?
    ) async throws -> _Gemini.File {
        guard let mimeType = mimeType else {
            throw _Gemini.APIError.unknown(message: "MIME type is required when using fileURL")
        }
        
        do {
            let data = try Data(contentsOf: fileURL)
            let file = try await uploadFile(
                fileData: data,
                mimeType: mimeType,
                displayName: UUID().uuidString
            )
            return file
        } catch let error as NSError where error.domain == NSCocoaErrorDomain {
            throw _Gemini.APIError.unknown(message: "Failed to read file: \(error.localizedDescription)")
        }
    }
    
    internal func processRemoteURL(
        url: URL,
        mimeType: HTTPMediaType?
    ) async throws -> _Gemini.File {
        guard let mimeType = mimeType else {
            throw _Gemini.APIError.unknown(message: "MIME type is required when using remote URL")
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw _Gemini.APIError.unknown(message: "Failed to download file from URL")
        }
        
        let file = try await uploadFile(
            fileData: data,
            mimeType: mimeType,
            displayName: UUID().uuidString
        )
        return file
    }
    
    
    public func waitForFileProcessing(
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
