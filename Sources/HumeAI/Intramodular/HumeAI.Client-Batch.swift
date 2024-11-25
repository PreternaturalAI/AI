//
//  HumeAI.Client-Jobs.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func startInferenceJob(
        files: [HumeAI.FileInput],
        models: [HumeAI.Model]
    ) async throws -> HumeAI.Job {
        let input = HumeAI.APISpecification.RequestBodies.BatchInferenceJobInput(
            files: files.map { .init(url: $0.url, mimeType: $0.mimeType, metadata: $0.metadata) },
            models: models,
            callback: nil
        )
        return try await run(\.startInferenceJob, with: input)
    }
    
    public func getJobDetails(
        id: String
    ) async throws -> HumeAI.Job {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        return try await run(\.getJobDetails, with: input)
    }
}
