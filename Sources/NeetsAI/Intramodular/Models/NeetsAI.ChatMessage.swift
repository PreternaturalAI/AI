//
//  NeetsAI.ChatMessage.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import Foundation

extension NeetsAI {
    public struct ChatMessage: Codable, Hashable {
        public let role: String
        public let content: String
        public let toolCalls: [String]?
        
        private enum CodingKeys: String, CodingKey {
            case role
            case content
            case toolCalls = "tool_calls"
        }
    }
    
    public struct ChatCompletion: Codable {
        public let id: String
        public let object: String
        public let created: Int
        public let model: String
        public let choices: [Choice]
        public let usage: Usage
        
        public struct Choice: Codable {
            public let index: Int
            public let message: ChatMessage
            public let logprobs: String?
            public let finishReason: String?
            public let stopReason: String?
            
            private enum CodingKeys: String, CodingKey {
                case index
                case message
                case logprobs
                case finishReason = "finish_reason"
                case stopReason = "stop_reason"
            }
        }
        
        public struct Usage: Codable {
            public let promptTokens: Int
            public let totalTokens: Int
            public let completionTokens: Int
            
            private enum CodingKeys: String, CodingKey {
                case promptTokens = "prompt_tokens"
                case totalTokens = "total_tokens"
                case completionTokens = "completion_tokens"
            }
        }
    }
}
