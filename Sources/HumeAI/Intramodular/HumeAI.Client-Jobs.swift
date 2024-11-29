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
    public func startTrainingJob(
        datasetId: String,
        name: String,
        description: String? = nil,
        configuration: [String: String]
    ) async throws -> HumeAI.JobID {
        let input = HumeAI.APISpecification.RequestBodies.TrainingJobInput(
            datasetId: datasetId,
            name: name,
            description: description,
            configuration: configuration
        )
        return try await run(\.startTrainingJob, with: input)
    }
    
    public func startCustomInferenceJob(
        modelId: String,
        files: [HumeAI.FileInput],
        configuration: [String: String]
    ) async throws -> HumeAI.JobID {
        let input = HumeAI.APISpecification.RequestBodies.CustomInferenceJobInput(
            modelId: modelId,
            files: files,
            configuration: configuration
        )
        return try await run(\.startCustomInferenceJob, with: input)
    }
}
