//
// Copyright (c) Vatsal Manot
//

import Foundation

extension Jina {
    public struct Embeddings: Codable, Hashable, Sendable {
        public let model: String
        public let object: String
        public let data: [EmbeddingData]
        public let usage: Usage
    }
}

extension Jina.Embeddings {
    public struct EmbeddingData: Codable, Hashable, Sendable {
        public let object: String
        public let embedding: Embedding
        public let index: Int
    }
    
    public struct Embedding: Codable, Hashable, Sendable {
        public let float: [Float]
    }
}

extension Jina.Embeddings {
    public struct Usage: Codable, Hashable, Sendable {
        public let promptTokens: Int
        public let totalTokens: Int
    }
}
