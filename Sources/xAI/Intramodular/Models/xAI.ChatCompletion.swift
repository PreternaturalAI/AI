

import Foundation

extension xAI {
    public struct ChatCompletion: Codable, Hashable, Sendable {
        
        public struct Choice: Codable, Hashable, Sendable {
            public enum FinishReason: String, Codable, Hashable, Sendable {
                case stop = "stop"
                case length = "length"
                case modelLength = "model_length"
                case toolCalls = "tool_calls"
            }
            
            public let index: Int
            public let message: ChatMessage
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
        public var model: Model
        public var choices: [Choice]
        public let usage: Usage
        public let systemFingerprint: String
    }
}

