//
// Copyright (c) Vatsal Manot
//

import CoreMI
import NaturalLanguage
import Swallow

/// A `TextEmbeddingsRequestHandling` that wraps Apple's system embedding models.
public final class NLEmbeddingProvider: TextEmbeddingsRequestHandling {
    public enum EmbeddingType {
        case word
        case sentence
    }
    
    public let embeddingType: EmbeddingType
    public let language: NLLanguage
    
    public init(
        embeddingType: EmbeddingType,
        language: NLLanguage
    ) {
        self.embeddingType = embeddingType
        self.language = language
    }
    
    public var model: ModelIdentifier {
        get throws {
            let languageName = try NLLanguage.Name(language).unwrap().rawValue
            
            switch embeddingType {
                case .word:
                    return .init(
                        provider: .apple,
                        name: "word-embedding-\(languageName)",
                        revision: NLEmbedding.currentRevision(for: language).description
                    )
                case .sentence:
                    return .init(
                        provider: .apple,
                        name: "sentence-embedding-\(languageName)",
                        revision: NLEmbedding.currentRevision(for: language).description
                    )
            }
        }
    }
    
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        let model: ModelIdentifier = try self.model
        let embedding: NLEmbedding
        
        if let requestedModel = request.model {
            try _tryAssert(requestedModel == model)
        }
        
        switch embeddingType {
            case .word:
                embedding = try NLEmbedding.wordEmbedding(for: language).unwrap()
            case .sentence:
                embedding = try NLEmbedding.sentenceEmbedding(for: language).unwrap()
        }
        
        return try TextEmbeddings(
            model: model,
            data: request.input.map { string in
                TextEmbeddings.Element(
                    text: string,
                    embedding: _RawTextEmbedding(
                        rawValue: try embedding.vector(for: string).unwrap()
                    ),
                    model: model
                )
            }
        )
    }
}

extension ModelIdentifier {
    /// The on-device word-embedding model provided by Apple.
    public static func wordEmbedding(
        _ language: NLLanguage.Name
    ) -> Self {
        Self(
            provider: .apple,
            name: "word-embedding-\(language.rawValue)",
            revision: NLEmbedding.currentRevision(for: .init(rawValue: language.rawValue)).description
        )
    }
    
    /// The on-device sentence-embedding model provided by Apple.
    public static func sentenceEmbedding(
        _ language: NLLanguage.Name
    ) -> Self {
        Self(
            provider: .apple,
            name: "sentence-embedding-\(language.rawValue)",
            revision: NLEmbedding.currentRevision(for: .init(rawValue: language.rawValue)).description
        )
    }
}
