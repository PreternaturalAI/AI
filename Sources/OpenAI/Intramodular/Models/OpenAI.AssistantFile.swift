//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public final class AssistantFile: OpenAI.Object {
        private enum CodingKeys: String, CodingKey {
            case id
            case createdAt = "created_at"
            case assistantID = "assistant_id"
        }
        
        public struct DeletionStatus: Decodable {
            public let id: String
            public let object: String
            public let deleted: Bool
        }
        
        let id: String
        let createdAt: Int
        let assistantID: String
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(forKey: .id)
            self.createdAt = try container.decode(forKey: .createdAt)
            self.assistantID = try container.decode(forKey: .assistantID)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(assistantID, forKey: .assistantID)
        }
    }    
}
