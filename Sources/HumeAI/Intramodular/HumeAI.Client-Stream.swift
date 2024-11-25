//
//  HumeAI.Client-Stream.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func streamInference(
        id: String,
        file: Data,
        models: [HumeAI.Model],
        metadata: [String: String]? = nil
    ) async throws -> HumeAI.Job {
        let input = HumeAI.APISpecification.RequestBodies.StreamInput(
            id: id,
            file: file,
            models: models,
            metadata: metadata
        )
        return try await run(\.streamInference, with: input)
    }
}
