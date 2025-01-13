//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import NetworkKit
import Swift

extension OpenAI.File {
    @HadeanIdentifier("sihim-nosam-dujaz-zafuj")
    public struct ID: Codable, RawRepresentable, Hashable, Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(from decoder: any Decoder) throws {
            rawValue = try String(from: decoder)
        }
        
        public func encode(to encoder: any Encoder) throws {
            try rawValue.encode(to: encoder)
        }
    }    
}

extension OpenAI {
    public final class File: OpenAI.Object, Identifiable {
        private enum CodingKeys: String, CodingKey {
            case id
            case bytes
            case createdAt
            case filename
            case purpose
        }
        
        public enum Purpose: String, Codable, Hashable, Sendable {
            case assistants
            case fineTune = "fine-tune"
            case answers
            case search
            case classifications
        }

        public let id: ID
        public let bytes: Int
        public let createdAt: Date // FIXME?
        public let filename: String
        public let purpose: String
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(forKey: .id)
            self.bytes = try container.decode(forKey: .bytes)
            self.createdAt = try container.decode(forKey: .createdAt)
            self.filename = try container.decode(forKey: .filename)
            self.purpose = try container.decode(forKey: .purpose)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(bytes, forKey: .bytes)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(filename, forKey: .filename)
            try container.encode(purpose, forKey: .purpose)
        }
    }
}

// MARK: - Conformances

extension OpenAI.File: CustomStringConvertible {
    public var description: String {
        filename 
    }
}

// MARK: - Auxiliary

extension OpenAI.File {
    public struct DeletionStatus: Codable, Hashable, Sendable {
        public let id: OpenAI.File.ID
        public let object: OpenAI.ObjectType
        public let deleted: Bool
    }
}
