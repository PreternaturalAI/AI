//
//  File.swift
//  AI
//
//  Created by Vatsal Manot on 12/27/24.
//

import CoreMI
import FoundationX
import Swallow

extension _Gemini.Client {
    public final class FileSpace: CoreMI._ServiceProvisionedFileSpace {
        let client: _Gemini.Client
        
        init(client: _Gemini.Client) {
            self.client = client
        }
        
        public func listFiles() async throws -> AnyAsyncSequence<CoreMI._ServiceProvisionedFile.ID> {
            let files: [_Gemini.File] = try await client.listFiles(pageSize: 100).files ?? []; // FIXME!!!: (@vmanot)
            
            return try await AnyAsyncSequence(files.asyncMap({ try await client._convert($0).id }))
        }
        
        public func file(
            for fileID: CoreMI._ServiceProvisionedFile.ID
        ) async throws -> CoreMI._ServiceProvisionedFile {
            let fileID = try fileID.as(_Gemini.File.ID.self)
            
            return try await client._convert(client.getFile(name: fileID.name))
        }
        
        public func status(
            ofFile file: CoreMI._ServiceProvisionedFile.ID
        ) async throws -> CoreMI._ServiceProvisionedFileStatus {
            let fileID = try file.as(_Gemini.File.ID.self)
            let file: _Gemini.File = try await client.getFile(name: fileID.name)
            
            return CoreMI._ServiceProvisionedFileStatus(
                isReady: file.state == .active
            )
        }

        public func uploadFile<T>(
            contents: T,
            metadata: CoreMI._ServiceProvisionedFile.Metadata
        ) async throws -> CoreMI._ServiceProvisionedFile {
            let serializedContents: Data = try cast(contents, to: Data.self)
            
            let file: _Gemini.File = try await Task.retrying(maxRetryCount: 5) {
                try await self.client.uploadFile(
                    from: serializedContents,
                    ofSwiftType: Swift.type(of: contents),
                    mimeType: nil,
                    displayName: metadata.displayName ?? "File"
                )
            }.value
            
            return try await client._convert(file)
        }
        
        public func delete(
            file: CoreMI._ServiceProvisionedFile.ID
        ) async throws {
            let fileID = try file.as(_Gemini.File.ID.self)
            
            try await client.deleteFile(fileURL: fileID.uri)
        }
    }
}

extension _Gemini.Client {
    public func file<Key>(
        for id: CoreMI.ServiceFileDrive<Key>.Item.ID
    ) async throws -> _Gemini.File {
        let fileID: _Gemini.File.ID = try id.remoteFileID.as(_Gemini.File.ID.self)
        
        return try await getFile(name: fileID.name)
    }
    
    public func file<Key>(
        for file: CoreMI.ServiceFileDrive<Key>.Item
    ) async throws -> _Gemini.File {
        try await self.file(for: file.id)
    }
    
    public func files<Key>(
        for identifiers: [CoreMI.ServiceFileDrive<Key>.Item.ID]
    ) async throws -> [_Gemini.File] {
        try await identifiers.asyncMap({ id in
            try await file(for: id)
        })
    }
    
    public func file<Key>(
        for items: [CoreMI.ServiceFileDrive<Key>.Item]
    ) async throws -> [_Gemini.File] {
        try await files(for:  items.map(\.id))
    }
}

extension _Gemini.File: CoreMI._ServiceProvisionedFileConvertible {
    public init(
        from file: CoreMI._ServiceProvisionedFile,
        context: CoreMI._ServiceProvisionedFileConversionContext
    ) async throws {
        let client: _Gemini.Client = try cast(context.client)
        let fileID: _Gemini.File.ID = try file.id.as(_Gemini.File.ID.self)
        
        self = try await client.getFile(name: fileID.name)
    }
    
    public func __conversion(
        context: CoreMI._ServiceProvisionedFileConversionContext
    ) async throws -> CoreMI._ServiceProvisionedFile {
        let fileID = CoreMI._ServiceProvisionedFile.ID(erasing: self.id)
        let fileMetadata = CoreMI._ServiceProvisionedFile.Metadata(displayName: self.name.rawValue)
        
        return CoreMI._ServiceProvisionedFile(
            id: fileID,
            metadata: fileMetadata
        )
    }
}
