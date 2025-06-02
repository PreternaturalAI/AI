//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence

extension TogetherAI.Client: TextEmbeddingsRequestHandling {
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        guard !request.input.isEmpty else {
            return TextEmbeddings(
                model: .init(from: TogetherAI.Model.Embedding.togetherM2Bert80M2KRetrieval),
                data: []
            )
        }
        
        let model: ModelIdentifier = request.model ?? ModelIdentifier(from: TogetherAI.Model.Embedding.togetherM2Bert80M2KRetrieval)
        let embeddingModel = try TogetherAI.Model.Embedding(rawValue: model.name).unwrap()
        
        let embeddings = try await createEmbeddings(
            for: embeddingModel,
            input: request.input
        ).data
        
        try _tryAssert(request.input.count == embeddings.count)
        
        return TextEmbeddings(
            model: .init(from: TogetherAI.Model.Embedding.togetherM2Bert80M2KRetrieval),
            data: request.input.zip(embeddings).map {
                TextEmbeddings.Element(
                    text: $0,
                    embedding: $1.embedding,
                    model: model
                )
            }
        )
    }
}
