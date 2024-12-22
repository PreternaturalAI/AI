//
// Copyright (c) Preternatural AI, Inc.
//

import Dispatch
import Foundation
import Merge
import NetworkKit
import Swallow

extension _Gemini.Client {
    
    public func uploadFile(
        from data: Data,
        mimeType: HTTPMediaType,
        displayName: String
    ) async throws -> _Gemini.File {
        guard !displayName.isEmpty else {
            throw FileProcessingError.invalidFileName
        }
        
        do {
            let input = _Gemini.APISpecification.RequestBodies.FileUploadInput(
                fileData: data,
                mimeType: mimeType.rawValue,
                displayName: displayName
            )
            
            let response = try await run(\.uploadFile, with: input)
            
            return response.file
        } catch {
            throw _Gemini.APIError.unknown(message: "File upload failed: \(error.localizedDescription)")
        }
    }
    
    public func uploadFile(
        from url: URL,
        mimeType: HTTPMediaType,
        displayName: String?
    ) async throws -> _Gemini.File {
        let data: Data
        
        if url.isFileURL {
            // Handle local file
            do {
                data = try Data(contentsOf: url)
            } catch let error as NSError where error.domain == NSCocoaErrorDomain {
                throw _Gemini.APIError.unknown(message: "Failed to read local file: \(error.localizedDescription)")
            }
        } else {
            // Handle remote file
            let (remoteData, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                throw _Gemini.APIError.unknown(message: "Failed to download remote file from URL")
            }
            
            data = remoteData
        }
        
        return try await uploadFile(
            from: data,
            mimeType: mimeType,
            displayName: displayName ?? UUID().stringValue
        )
    }
    
    public func getFile(
        name: _Gemini.File.Name
    ) async throws -> _Gemini.File {
        guard !name.rawValue.isEmpty else {
            throw FileProcessingError.invalidFileName
        }
        
        do {
            let input = _Gemini.APISpecification.RequestBodies.FileStatusInput(name: name)
            
            return try await run(\.getFile, with: input)
        } catch {
            throw _Gemini.APIError.unknown(message: "Failed to get file status: \(error.localizedDescription)")
        }
    }
    
    public func listFiles(
        pageSize: Int? = nil,
        pageToken: String? = nil
    ) async throws -> _Gemini.FileList {
        do {
            let input = _Gemini.APISpecification.RequestBodies.FileListInput(
                pageSize: pageSize,
                pageToken: pageToken
            )
            
            return try await run(\.listFiles, with: input)
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
    
    public func pollFileUntilActive(
        name: _Gemini.File.Name,
        maxRetryCount: Int? = nil,
        retryDelay: DispatchTimeInterval = .seconds(1)
    ) async throws -> _Gemini.File {
        guard !name.rawValue.isEmpty else {
            throw FileProcessingError.invalidFileName
        }
        
        let result = try await Task.retrying(
            priority: nil,
            maxRetryCount: maxRetryCount ?? Int.max,
            retryDelay: retryDelay
        ) {
            let file: _Gemini.File = try await self.getFile(name: name)
            
            switch file.state {
                case .active:
                    return file
                case .processing:
                    throw FileProcessingError.fileStillProcessing
            }
        }.value
        
        return result
    }
}

// MARK: - Error Handling

fileprivate enum FileProcessingError: Error {
    case invalidFileName
    case fileStillProcessing
}
