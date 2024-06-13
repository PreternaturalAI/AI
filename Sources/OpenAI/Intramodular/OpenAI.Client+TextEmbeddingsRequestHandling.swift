//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence

extension OpenAI.Client: TextEmbeddingsRequestHandling {
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        guard !request.input.isEmpty else {
            return TextEmbeddings(
                model: .init(from: OpenAI.Model.Embedding.ada),
                data: []
            )
        }
        
        let model: ModelIdentifier = request.model ?? ModelIdentifier(from: OpenAI.Model.Embedding.ada)
        let embeddingModel = try OpenAI.Model.Embedding(rawValue: model.name).unwrap()
        
        let embeddings = try await createEmbeddings(
            model: embeddingModel,
            for: request.input
        ).data
        
        try _tryAssert(request.input.count == embeddings.count)
        
        return TextEmbeddings(
            model: .init(from: OpenAI.Model.Embedding.ada),
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
