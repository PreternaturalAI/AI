//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import FoundationX
import Merge
import Swallow

extension CoreMI {
    public struct _ServiceProvisionedFileStatus: Codable, Hashable, Sendable {
        public let isReady: Bool
        
        public init(isReady: Bool) {
            self.isReady = isReady
        }
    }
    
    public struct _ServiceProvisionedFile: Codable, Hashable, Identifiable, Sendable {
        public struct ID: Codable, Hashable, Sendable {
            public let rawValue: AnyPersistentIdentifier
            
            public init<T: Codable & Hashable & Sendable>(
                erasing x: T
            ) {
                self.rawValue = AnyPersistentIdentifier(erasing: x)
            }
            
            public func `as`<T>(_ type: T.Type) throws -> T {
                try rawValue.as(type)
            }
        }
        
        public struct Metadata: Codable, Hashable, Initiable, Sendable {
            public var displayName: String?
            
            public init(displayName: String?) {
                self.displayName = displayName
            }
            
            public init() {
                self.init(displayName: nil)
            }
        }
        
        public let id: ID
        public let metadata: Metadata
        
        public init(id: ID, metadata: Metadata) {
            self.id = id
            self.metadata = metadata
        }
    }
    
    public protocol _ServiceProvisionedFileSpace {
        func listFiles() async throws -> AnyAsyncSequence<CoreMI._ServiceProvisionedFile.ID>
        func file(for id: CoreMI._ServiceProvisionedFile.ID) async throws -> CoreMI._ServiceProvisionedFile
        
        func uploadFile<T>(
            contents: T,
            metadata: CoreMI._ServiceProvisionedFile.Metadata
        ) async throws -> CoreMI._ServiceProvisionedFile
        
        func status(
            ofFile file: CoreMI._ServiceProvisionedFile.ID
        ) async throws -> CoreMI._ServiceProvisionedFileStatus
        
        func requestDeletion(
            ofFile _: CoreMI._ServiceProvisionedFile.ID
        ) async throws
        
        func delete(
            file: CoreMI._ServiceProvisionedFile.ID
        ) async throws
    }
}

extension CoreMI {
    fileprivate enum _ServiceProvisionedFilePollingError: Error {
        case fileNotReady
    }
}

extension CoreMI._ServiceProvisionedFileSpace {
    func _pollUntilReady(
        for file: CoreMI._ServiceProvisionedFile.ID,
        maxRetryCount: Int? = nil,
        retryDelay: DispatchTimeInterval = .seconds(1)
    ) async throws -> CoreMI._ServiceProvisionedFile {
        try await Task.retrying(
            priority: nil,
            maxRetryCount: maxRetryCount ?? Int.max,
            retryDelay: retryDelay
        ) {
            let fileStatus = try await self.status(ofFile: file)
            
            guard fileStatus.isReady else {
                throw CoreMI._ServiceProvisionedFilePollingError.fileNotReady
            }
        }.value
        
        return try await self.file(for: file)
    }
}

extension CoreMI._ServiceProvisionedFileSpace {
    public func requestDeletion(
        ofFile file: CoreMI._ServiceProvisionedFile.ID
    ) async throws {
        try await delete(file: file)
    }
}

extension CoreMI {
    public struct _ServiceProvisionedFileConversionContext {
        public let client: any CoreMI._ServiceClientProtocol
        
        public init(client: any CoreMI._ServiceClientProtocol) {
            self.client = client
        }
    }
    
    public protocol _ServiceProvisionedFileConvertible {
        init(
            from file: CoreMI._ServiceProvisionedFile,
            context: CoreMI._ServiceProvisionedFileConversionContext
        ) async throws
        
        func __conversion(
            context: CoreMI._ServiceProvisionedFileConversionContext
        ) async throws -> CoreMI._ServiceProvisionedFile
    }
}

extension CoreMI {
    public struct _AnyServiceFileDriveConfiguration {
        public let storageDirectory: URL?
        public let indexFileURL: URL
    }
    
    public class _AnyServiceFileDrive {
        let configuration: _AnyServiceFileDriveConfiguration
        let owner: any CoreMI._ServiceClientProtocol
        let remote: any _ServiceProvisionedFileSpace
        
        init(
            configuration: _AnyServiceFileDriveConfiguration,
            owner: any CoreMI._ServiceClientProtocol,
            remote: any CoreMI._ServiceProvisionedFileSpace
        ) throws {
            self.owner = owner
            self.configuration = configuration
            self.remote = remote
        }
    }
    
    /// This class binds a remote-service managed file space (for e.g. OpenAI's files/Gemini's files for your project) that you control partially to a local file storage that you control fully.
    public final class ServiceFileDrive<Key: Codable & Hashable & Sendable>: CoreMI._AnyServiceFileDrive, ObjectDidChangeObservableObject {
        public struct Item: Codable, Hashable, Identifiable, Sendable {
            public struct ID: Codable, Hashable, Sendable {
                public let key: Key
                public let remoteFileID: _ServiceProvisionedFile.ID
            }
            
            public let id: ID
            public let metadata: _ServiceProvisionedFile.Metadata
            public let fileURL: URL?
        }
        
        public struct _IndexData: Codable, Hashable, Initiable, Sendable {
            public var items: [Key: Item]
            
            public init() {
                self.items = [:]
            }
        }
        
        @FileStorage(
            location: .temporaryDirectory.appending(.file(UUID().uuidString)),
            coder: HadeanTopLevelCoder(coder: .json)
        )
        var _indexData: _IndexData = .init()
        
        public var items: [Item] {
            Array(_indexData.items.values)
        }
        
        override init(
            configuration: _AnyServiceFileDriveConfiguration,
            owner: any CoreMI._ServiceClientProtocol,
            remote: any CoreMI._ServiceProvisionedFileSpace
        ) throws {
            try self.__indexData.setLocation(configuration.indexFileURL)
            
            try super.init(
                configuration: configuration,
                owner: owner,
                remote: remote
            )
        }
        
        public func uploadFile<T>(
            withContents contents: T,
            metadata: CoreMI._ServiceProvisionedFile.Metadata,
            forKey key: Key
        ) async throws -> Item {
            assert(configuration.storageDirectory == nil)
            
            let file: CoreMI._ServiceProvisionedFile = try await remote.uploadFile(contents: contents, metadata: metadata)
            let item: Item = .init(
                id: .init(
                    key: key,
                    remoteFileID: file.id
                ),
                metadata: metadata,
                fileURL: nil
            )
            
            self._indexData.items[key] = item
            
            return item
        }
        
        func _getReadyItem(forKey key: Key) async throws -> Item {
            let result: Item = try self._indexData.items[key].unwrap()
            let id = result.id
            
            let latestFile = try await remote._pollUntilReady(for: id.remoteFileID)

            _ = latestFile
            
            return result
        }
        
        public subscript(
            key: Key
        ) -> Item {
            get async throws {
                try await _getReadyItem(forKey: key)
            }
        }

        public subscript(
            item id: Item.ID
        ) -> Item {
            get async throws {
                let key: Key = try self._indexData.items.values.first(where: { $0.id == id }).unwrap().id.key
                
                return try await self[key]
            }
        }
        
        public func items(
            forKeys keys: [Key]
        ) async throws -> [Item] {
            try await keys.asyncMap({ key in
                try await self[key]
            })
        }
        
        public func erase() async throws {
            let itemsByKey = _indexData.items
            
            for (_, item) in itemsByKey {
                let fileID: CoreMI._ServiceProvisionedFile.ID = item.id.remoteFileID
                
                try await remote.delete(file: fileID)
            }
            
            self._indexData.items = [:]
        }
    }
}

extension CoreMI.ServiceFileDrive {
    public func uploadFile<T>(
        withContents contents: T,
        displayName: String,
        forKey key: Key
    ) async throws -> Item {
        try await self.uploadFile(
            withContents: contents,
            metadata: .init(displayName: displayName),
            forKey: key
        )
    }
}

extension CoreMI._ServiceClientProtocol {
    public func _globalFileSpace() -> any CoreMI._ServiceProvisionedFileSpace {
        fatalError(.unimplemented)
    }
    
    public func fileDrive<Key>(
        storingFilesInDirectory storageDirectory: URL?,
        indexFileURL: URL,
        keyedBy: Key.Type
    ) throws -> CoreMI.ServiceFileDrive<Key> {
        assert(storageDirectory == nil, "storageDirectory is currently unsupported")
        
        return try CoreMI.ServiceFileDrive(
            configuration: .init(
                storageDirectory: storageDirectory,
                indexFileURL: indexFileURL
            ),
            owner: self,
            remote: _globalFileSpace()
        )
    }
}

extension CoreMI._ServiceClientProtocol {
    public func _convert<T: CoreMI._ServiceProvisionedFileConvertible>(
        _ x: T
    ) async throws -> CoreMI._ServiceProvisionedFile {
        let context = CoreMI._ServiceProvisionedFileConversionContext(client: self)
        
        return try await x.__conversion(context: context)
    }
}
/*// file drive's purpose is to manage files that you give it and keep syncing it to Gemini/OpenAI
 // file drive will keep a copy of the files that you give it locally, and also upload it to Gemini/OpenAI
 let drive: ServiceFileDrive<WWDCSession> = try await geminiClient.fileDrive(
 storingFilesInDirectory: <some url>,
 indexFileURL: .automatic,
 keyedBy: WWDCSession.self
 )
 
 let item: ServiceFileDrive.Item = drive.upload(data: myData, forKey: wwdcSession)
 
 try drive.data(forKey: wwdcSession)
 
 try await drive.eraseLocalCopiesOnly()
 try await drive.erase()
 try await drive.delete(forKey: wwdcSession)
 
 */

