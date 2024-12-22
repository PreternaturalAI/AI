//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Merge
import NetworkKit

extension Ollama.APISpecification.ResponseBodies {
    public struct GenerateCompletion: Codable, Hashable, Sendable {
        public let model: Ollama.Model.ID
        public let createdAt: Date
        public let response: String
        public let context: [Int]?

        public let done: Bool

        public let totalDuration: Int?
        public let loadDuration: Int?
        public let promptEvalCount: Int?
        public let promptEvalDuration: Int?
        public let evalCount: Int?
        public let evalDuration: Int?
    }
    
    public struct GenerateChatCompletion: Codable, Hashable, Sendable {
        public let model: Ollama.Model.ID
        public let createdAt: Date
        public let message: Ollama.ChatMessage?
        
        public let done: Bool
        
        public let totalDuration: Int?
        public let loadDuration: Int?
        public let promptEvalCount: Int?
        public let promptEvalDuration: Int?
        public let evalCount: Int?
        public let evalDuration: Int?
    }
        
    public struct GetModels: Codable, Hashable, Sendable {
        public let models: [Ollama.Model]
    }
    
    public struct GetModelInfo: Codable, Hashable, Sendable {
        public let modelfile: String
        public let parameters: String?
        public let template: String?
        public let license: String?
        public var details: Details?
        
        public struct Details: Codable, Hashable, Sendable {
            public var format: String?
            public var families: String?
            public var parameterSize: String?
            public var quantizationLevel: String?
        }
    }
}
