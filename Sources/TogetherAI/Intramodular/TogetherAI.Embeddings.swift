//
// Copyright (c) Vatsal Manot
//

import Foundation

extension TogetherAI {
    public struct Embeddings: Codable, Hashable, Sendable {
        public let model: String
        public let object: String
        public let data: [EmbeddingData]
    }
}

extension TogetherAI.Embeddings {
    public struct EmbeddingData: Codable, Hashable, Sendable {
        public let object: String
        public let embedding: [Double]
        public let index: Int
    }
}
