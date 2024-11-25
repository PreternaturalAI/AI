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
        file: Data,
        models: [HumeAI.Model],
        metadata: [String: String]? = nil
    ) async throws -> HumeAI.APISpecification.ResponseBodies.Job {
        let input = HumeAI.APISpecification.RequestBodies.StreamInput(file: file, models: models, metadata: metadata)
        return try await run(\.streamInference, with: input)
    }
}
