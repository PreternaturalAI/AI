//
// Copyright (c) Vatsal Manot
//

import Dispatch
import Foundation
import Merge
import NetworkKit
import Swallow

extension _Gemini.Client {
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
    
    func _processedFile(
        from fileSource: _Gemini.FileSource,
        mimeType: HTTPMediaType?
    ) async throws -> _Gemini.File {
        enum FileGenerationError: Swift.Error {
            case missingFileName
        }
        
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
        
        guard let name: _Gemini.File.Name = initialFile.name else {
            throw FileGenerationError.missingFileName
        }
        
        let result = try await pollFileUntilActive(name: name)
        
        return result
    }
}

// MARK: - Error Handling

fileprivate enum FileProcessingError: Error {
    case invalidFileName
    case fileStillProcessing
    case invalidFileState(state: String)
    case fileNotFound(name: String)
}
