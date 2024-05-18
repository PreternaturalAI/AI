//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/16/24.
//

import LargeLanguageModels
import Swallow
import Foundation

extension OpenAI {
    public class VectorStore: OpenAI.Object {
        private enum CodingKeys: String, CodingKey {
            case id
            case object
            case createdAt
            case name
            case bytes
            case usageBytes
            case fileCounts
            case status
            case expiresAfter
            case expiresAt
            case lastActiveAt
            case metadata
            case deleted
        }
        
        /// The identifier, which can be referenced in API endpoints.
        public let id: String
        
        /// The object type, which is always vector_store.
        public let object: OpenAI.ObjectType
        
        /// The Unix timestamp (in seconds) for when the vector store was created.
        public let createdAt: Int?
        
        /// The name of the vector store.
        public let name: String?
        
        /// The total number of bytes used by the files in the vector store.
        public let usageBytes: Int?
        public let bytes: Int?
        
        /// File Counts Object Keys:
        /// in_progress (integer) - The number of files that are currently being processed.
        /// completed (integer) - The number of files that have been successfully processed.
        /// failed (integer) - The number of files that have failed to process.
        /// cancelled (integer) - The number of files that were cancelled.
        /// total (integer) - The total number of files.
        public struct FileCounts: Codable, Hashable, Sendable {
            let inProgress: Int
            let completed: Int
            let failed: Int
            let cancelled: Int
            let total: Int
        }
        public let fileCounts: FileCounts?
        
        /// The status of the vector store, which can be either expired, in_progress, or completed. A status of completed indicates that the vector store is ready for use.
        public enum Status: String, Codable, Hashable, Sendable {
            case inProgress
            case completed
        }
        public let status: Status?
        
        /// The expiration policy for a vector store.
        /// anchor (string) - Anchor timestamp after which the expiration policy applies. Supported anchors: last_active_at.
        /// days (integer) - The number of days after the anchor time that the vector store will expire.
        public struct ExpiresAfter: Codable, Hashable, Sendable {
            let anchor: String
            let days: Int
        }
        public let expiresAfter: ExpiresAfter?
        
        /// The Unix timestamp (in seconds) for when the vector store will expire.
        public let expiresAt: Int?
        
        /// The Unix timestamp (in seconds) for when the vector store was last active.
        public let lastActiveAt: Int?
        
        /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
        public let metadata: [String: String]?
        
        public let deleted: Bool?
        
        // order options for list
        public enum Order: String, Codable, Hashable, Sendable {
            case ascending = "asc"
            case descending = "desc"
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
                        
            
            self.id = try container.decode(forKey: .id)
            self.object = try container.decode(forKey: .object)
            self.createdAt = try? container.decode(forKey: .createdAt)
            self.name = try? container.decode(forKey: .name)
            self.usageBytes = try? container.decode(forKey: .usageBytes)
            self.bytes = try? container.decode(forKey: .bytes)
            self.fileCounts = try? container.decode(forKey: .fileCounts)
            self.status = try? container.decode(forKey: .status)
            self.expiresAfter = try? container.decode(forKey: .expiresAfter)
            self.expiresAt = try? container.decode(forKey: .expiresAt)
            self.lastActiveAt = try? container.decode(forKey: .lastActiveAt)
            self.metadata = try? container.decode(forKey: .metadata)
            self.deleted = try? container.decode(forKey: .deleted)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(object, forKey: .object)
            try container.encode(createdAt, forKey: .createdAt)
            try? container.encode(name, forKey: .name)
            try? container.encode(usageBytes, forKey: .usageBytes)
            try? container.encode(bytes, forKey: .bytes)
            try? container.encode(fileCounts, forKey: .fileCounts)
            try? container.encode(status, forKey: .status)
            try? container.encode(expiresAfter, forKey: .expiresAfter)
            try? container.encode(expiresAt, forKey: .expiresAt)
            try? container.encode(lastActiveAt, forKey: .lastActiveAt)
            try? container.encode(metadata, forKey: .metadata)
            try? container.encode(metadata, forKey: .deleted)
        }
    }
}
