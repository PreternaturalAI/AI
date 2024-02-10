//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public final class TextCompletion: OpenAI.Object {
        private enum CodingKeys: String, CodingKey {
            case id
            case model
            case createdAt = "created"
            case choices
            case usage
        }
        
        public struct Choice: Codable, Hashable, Sendable {
            public enum FinishReason: String, Codable, Hashable, Sendable {
                case length = "length"
                case stop = "stop"
            }
            
            public let text: String
            public let index: Int
            public let logprobs: Int?
            public let finishReason: FinishReason?
        }
        
        public let id: String
        public let model: OpenAI.Model
        public let createdAt: Date
        public let choices: [Choice]
        public let usage: Usage
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(forKey: .id)
            self.model = try container.decode(forKey: .model)
            self.createdAt = try container.decode(forKey: .createdAt)
            self.choices = try container.decode(forKey: .choices)
            self.usage = try container.decode(forKey: .usage)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(model, forKey: .model)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(choices, forKey: .choices)
            try container.encode(usage, forKey: .usage)
        }
    }
}
