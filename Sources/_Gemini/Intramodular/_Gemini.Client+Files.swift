//
// Copyright (c) Vatsal Manot
//

import CoreMI
import Dispatch
import FoundationX
import Merge
import NetworkKit
import Swallow

fileprivate enum TempError: CustomStringError, Error {
    case fetchedResponse
    
    public var description: String {
        switch self {
            case .fetchedResponse:
                return "Got response url from header"
        }
    }
}

extension _Gemini.Client {
    public func uploadFile(
        from data: Data,
        ofSwiftType swiftType: Any.Type? = nil,
        mimeType: HTTPMediaType?,
        displayName: String
    ) async throws -> _Gemini.File {
        guard !displayName.isEmpty else {
            throw FileProcessingError.invalidFileName
        }
        
        var mimeType: String? = mimeType?.rawValue ?? _MediaAssetFileType(data)?.mimeType
        
        if mimeType == nil, let swiftType {
            mimeType = HTTPMediaType(_swiftType: swiftType)?.rawValue
        }
        
        let input = _Gemini.APISpecification.RequestBodies.StartFileUploadInput(
            fileData: data,
            mimeType: try mimeType.unwrap(),
            displayName: displayName
        )
        
        let uploadURLString: String = try await run(\.startFileUpload, with: input, options: _Gemini.APISpecification.Options(outputHeaderKey: .custom("x-goog-upload-url"))).value
        
        let result: _Gemini.APISpecification.ResponseBodies.FileUpload = try await run(\.finalizeFileUpload, with: _Gemini.APISpecification.RequestBodies.FinalizeFileUploadInput(data: data, uploadUrl: uploadURLString, fileSize: data.count))
        
        return result.file
    }
    
    
    public func uploadFile(
        from url: URL,
        mimeType: HTTPMediaType?,
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
