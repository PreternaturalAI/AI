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
        urls: [URL],
        models: HumeAI.APIModel
    ) async throws -> HumeAI.JobID {
        let input = HumeAI.APISpecification.RequestBodies.BatchInferenceJobInput(
            urls: urls,
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
    
    public func getJobPredictions(
        id: String
    ) async throws -> [HumeAI.JobPrediction] {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        return try await run(\.getJobPredictions, with: input)
    }
    public func listJobs() async throws -> [HumeAI.Job] {
        return try await run(\.listJobs, with: ())
    }
    
    public func getJobArtifacts(id: String) async throws -> [String: String] {
        let input = HumeAI.APISpecification.PathInput.ID(id: id)
        return try await run(\.getJobArtifacts, with: input)
    }
}
