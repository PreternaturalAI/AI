//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public final class Embedding: OpenAI.Object, Sendable {
        private enum CodingKeys: String, CodingKey {
            case embedding
            case index
        }
        
        public let embedding: [Double]
        public let index: Int
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.embedding = try container.decode(forKey: .embedding)
            self.index = try container.decode(forKey: .index)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(embedding, forKey: .embedding)
            try container.encode(index, forKey: .index)
        }
    }
}

// MARK: - Conformances

extension OpenAI.Embedding: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(embedding)
        hasher.combine(index)
    }
    
    public static func == (lhs: OpenAI.Embedding, rhs: OpenAI.Embedding) -> Bool {
        lhs.embedding == rhs.embedding && lhs.index == rhs.index
    }
}
