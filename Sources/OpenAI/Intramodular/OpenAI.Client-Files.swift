//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI.Client {
    public func uploadFileWithData(
        _ data: Data,
        named filename: String,
        mimeType: String,
        purpose: OpenAI.File.Purpose = .assistants
    ) async throws -> OpenAI.File {
        let request = OpenAI.APISpecification.RequestBodies.UploadFile(
            file: data,
            filename: filename,
            preferredMIMEType: mimeType,
            purpose: purpose
        )
        
        let file = try await run(\.uploadFile, with: request)
        
        return file
    }
    
    public func uploadFile(
        _ file: URL,
        named filename: String? = nil,
        purpose: OpenAI.File.Purpose = .assistants
    ) async throws -> OpenAI.File {
        let data = try Data(contentsOf: file)
        
        let request = OpenAI.APISpecification.RequestBodies.UploadFile(
            file: data,
            filename: try (filename ?? file._fileNameWithExtension).unwrap(),
            preferredMIMEType: try file._preferredMIMEType.unwrap(),
            purpose: purpose
        )
        
        let file = try await run(\.uploadFile, with: request)
        
        return file
    }
    
    public func listFiles(
        purpose: OpenAI.File.Purpose? = .assistants
    ) async throws -> OpenAI.List<OpenAI.File> {
        let result = try await run(\.listFiles, with: .init(purpose: purpose))
        
        return result
    }
    
    @discardableResult
    public func deleteFile(
        _ fileID: OpenAI.File.ID
    ) async throws -> OpenAI.File.DeletionStatus {
        let status: OpenAI.File.DeletionStatus = try await run(\.deleteFile, with: fileID)
        
        try _tryAssert(status.deleted)
        
        return status
    }
}
