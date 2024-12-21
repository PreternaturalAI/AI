//
// Copyright (c) Preternatural AI, Inc.
//

import Merge
import NetworkKit
import SwiftAPI

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
