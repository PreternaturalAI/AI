//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension VoyageAI {
    public struct Embeddings: Codable, Hashable, Sendable {
        public let model: String
        public let object: String
        public let data: [EmbeddingData]
        public let usage: Usage
    }
}

extension VoyageAI.Embeddings {
    public struct EmbeddingData: Codable, Hashable, Sendable {
        public let object: String
        public let embedding: [Float]
        public let index: Int
    }
}

extension VoyageAI.Embeddings {
    public struct Usage: Codable, Hashable, Sendable {
        public let totalTokens: Int
    }
}
