//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI.Client {
    public func createEmbeddings(
        model: OpenAI.Model.Embedding,
        for input: [String]
    ) async throws -> OpenAI.APISpecification.ResponseBodies.CreateEmbedding {
        try await run(\.createEmbeddings, with: .init(model: model, input: input))
    }
}
