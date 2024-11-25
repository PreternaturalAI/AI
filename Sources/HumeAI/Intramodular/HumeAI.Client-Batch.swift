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
        files: [HumeAI.APISpecification.RequestBodies.BatchInferenceJobInput.FileInput],
        models: [HumeAI.Model]
    ) async throws -> HumeAI.APISpecification.ResponseBodies.Job {
        let input = HumeAI.APISpecification.RequestBodies.BatchInferenceJobInput(
            files: files,
            models: models,
            callback: nil
        )
        return try await run(\.startInferenceJob, with: input)
    }
    
    public func getJobDetails(id: String) async throws -> HumeAI.APISpecification.ResponseBodies.Job {
        try await run(\.getJobDetails, with: id)
    }
}
