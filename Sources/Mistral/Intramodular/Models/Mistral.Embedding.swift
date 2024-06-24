//
// Copyright (c) Vatsal Manot
//

import Foundation

extension Mistral {
    public struct Embeddings: Codable, Hashable, Sendable {
        public let id: String
        public let object: String
        public let data: [EmbeddingData]
        public let model: String
        public let usage: Usage
    }
}

extension Mistral.Embeddings {
    public struct EmbeddingData: Codable, Hashable, Sendable {
        public let object: String
        public let embedding: [Double]
        public let index: Int
    }
}

extension Mistral.Embeddings {
    public struct Usage: Codable, Hashable, Sendable {
        public let promptTokens: Int
        public let totalTokens: Int
    }
}
