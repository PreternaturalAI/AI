//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import FoundationX
import Swallow

extension Mistral.APISpecification.ResponseBodies {
    public struct ChatCompletion: Codable, Hashable, Sendable {
        public struct Choice: Codable, Hashable, Sendable {
            public enum FinishReason: String, Codable, Hashable, Sendable {
                case stop = "stop"
                case length = "length"
                case modelLength = "model_length"
            }

            public let index: Int
            public let message: Mistral.ChatMessage
            public let finishReason: FinishReason
        }
        
        public struct Usage: Codable, Hashable, Sendable {
            public let promptTokens: Int
            public let completionTokens: Int
            public let totalTokens: Int
        }
        
        public var id: String
        public var object: String
        public var created: Date
        public var model: String
        public var choices: [Choice]
        public let usage: Usage
    }
}
