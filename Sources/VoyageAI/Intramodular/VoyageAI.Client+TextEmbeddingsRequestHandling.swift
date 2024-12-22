//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence

extension VoyageAI.Client: TextEmbeddingsRequestHandling {
        
    public var _availableModels: [ModelIdentifier]? {
        VoyageAI.Model.allCases.map({ $0.__conversion() })
    }
    
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        let model = request.model ?? VoyageAI.Model.voyage2.__conversion()
        let embeddingModel = try VoyageAI.Model(rawValue: model.name).unwrap()
        
        let embeddings: VoyageAI.Embeddings = try await createEmbeddings(
            for: embeddingModel,
            input: request.input
        )
        
        let textEmbeddings = embeddings.data.map {
            TextEmbeddings.Element(
                text: $0.object,
                embedding: $0.embedding.map { Double($0) },
                model: model)
        }
        
        return TextEmbeddings(
            model: model,
            data: textEmbeddings
        )
    }
}
