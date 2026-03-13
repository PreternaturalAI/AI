//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension TogetherAI {
    public final class Completion: Codable, Sendable {
        private enum CodingKeys: String, CodingKey {
            case id
            case object
            case model
            case createdAt = "created"
            case choices
            case usage
        }
        
        public struct Choice: Codable, Hashable, Sendable {
            public let text: String
            public let index: Int
            public let seed: Double
            public let finishReason: String
        }
        
        public struct Usage: Codable, Hashable, Sendable {
            public let promptTokens: Int
            public let completionTokens: Int
            public let totalTokens: Int
        }
        
        
        public let id: String
        public let model: TogetherAI.Model.Completion
        public let object: String
        public let createdAt: Date
        public let choices: [Choice]
        public let usage: Usage
    }
}

