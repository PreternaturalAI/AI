//
//  _Gemini.Client+Files.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Foundation
import NetworkKit

extension _Gemini.Client {
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
