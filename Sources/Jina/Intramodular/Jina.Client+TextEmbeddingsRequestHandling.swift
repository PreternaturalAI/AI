//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence

extension Jina.Client: TextEmbeddingsRequestHandling {
        
    public var _availableModels: [ModelIdentifier]? {
        Jina.Model.allCases.map({ $0.__conversion() })
    }
    
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        let model = request.model ?? Jina.Model.embeddingsV2BaseEn.__conversion()
        let embeddingModel = try Jina.Model(rawValue: model.name).unwrap()
        
        let embeddings: Jina.Embeddings = try await createEmbeddings(
            for: embeddingModel,
            input: request.input,
            encodingFormat: nil
        )
        
        let textEmbeddings = embeddings.data.map {
            TextEmbeddings.Element(
                text: $0.object,
                embedding: $0.embedding.float.map { Double($0) },
                model: model)
        }
        
        return TextEmbeddings(
            model: model,
            data: textEmbeddings
        )
    }
}
