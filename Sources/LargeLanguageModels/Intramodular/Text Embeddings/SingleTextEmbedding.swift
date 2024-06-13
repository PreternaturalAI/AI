//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import Swallow

@HadeanIdentifier("dapup-numuz-koluh-goduv")
public struct SingleTextEmbedding: Hashable, Sendable {
    public let text: String
    public let embedding: _RawTextEmbedding
    public let model: ModelIdentifier
    
    public init(
        text: String,
        embedding: _RawTextEmbedding,
        model: ModelIdentifier
    ) {
        self.text = text
        self.embedding = embedding
        self.model = model
    }
    
    public init(
        text: String,
        embedding: _RawTextEmbedding.RawValue,
        model: ModelIdentifier
    ) {
        self.init(
            text: text,
            embedding: .init(rawValue: embedding),
            model: model
        )
    }
}

// MARK: - Conformances

extension SingleTextEmbedding: Codable {
    public enum CodingKeys: CodingKey {
        case text
        case embedding
        case model
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.text = try container.decode(forKey: .text)
        self.embedding = try container.decode(forKey: .embedding)
        self.model = try container.decode(forKey: .model)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(text, forKey: .text)
        try container.encode(embedding, forKey: .embedding)
        try container.encode(model, forKey: .model)
    }
}
