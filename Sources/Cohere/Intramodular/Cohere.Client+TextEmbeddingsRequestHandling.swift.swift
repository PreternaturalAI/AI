//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import LargeLanguageModels

extension Cohere.Client: TextEmbeddingsRequestHandling {
        
    public var _availableModels: [ModelIdentifier]? {
        Cohere.Model.allCases.map({ $0.__conversion() })
    }
    
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        let model = request.model ?? Cohere.Model.embedEnglishV2.__conversion()
        let embeddingModel = Cohere.Model(rawValue: model.name)
        
        let embeddings: Cohere.Embeddings = try await createEmbeddings(
            for: embeddingModel,
            texts: request.input,
            inputType: .searchDocument,
            embeddingTypes: nil,
            truncate: nil
        )
        
        let textEmbeddingElements = zip(embeddings.texts, embeddings.embeddings).map { (text, embedding) in
            TextEmbeddings.Element(
                text: text,
                embedding: embedding.map { Double($0) },
                model: model)
        }
        
        return TextEmbeddings(model: model, data: textEmbeddingElements)
    }
}
