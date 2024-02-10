//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public final class Thread: OpenAI.Object {
        public typealias ID = _TypeAssociatedID<Thread, String>
        
        private enum CodingKeys: String, CodingKey {
            case id
            case createdAt
            case metadata
        }
        
        public let id: ID
        public let createdAt: Int
        public let metadata: [String: String]
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(forKey: .id)
            self.createdAt = try container.decode(forKey: .createdAt)
            self.metadata = try container.decode(forKey: .metadata)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(metadata, forKey: .metadata)
        }
    }
}
