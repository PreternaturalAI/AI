//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence

extension Mistral.Client: TextEmbeddingsRequestHandling {
        
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        let model = Mistral.Model.mistral_embed.__conversion()
        
        let embeddings: Mistral.Embeddings = try await createEmbeddings(for: request.input)
        let textEmbeddings = embeddings.data.map {
            TextEmbeddings.Element(
                text: $0.object,
                embedding: $0.embedding,
                model: model)
        }
        
        return TextEmbeddings(
            model: model,
            data: textEmbeddings
        )
    }
}
