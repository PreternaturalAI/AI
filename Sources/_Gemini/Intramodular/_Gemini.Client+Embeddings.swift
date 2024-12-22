//
// Copyright (c) Preternatural AI, Inc.
//

extension _Gemini.Client {
    public func generateEmbedding(
        text: String,
        model: _Gemini.Model = .text_embedding_004
    ) async throws -> [Double] {
        let content = _Gemini.APISpecification.RequestBodies.Content(
            role: "user",
            parts: [.text(text)]
        )
        
        let input = _Gemini.APISpecification.RequestBodies.EmbeddingInput(
            model: model,
            content: content
        )
        
        let response = try await run(\.generateEmbedding, with: input)
        
        return response.embedding.values
    }
}
