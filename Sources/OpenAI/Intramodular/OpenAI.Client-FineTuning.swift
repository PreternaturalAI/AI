//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI.Client {
    
    /// Creates a job that fine-tunes a specified model.
    /// - Parameters:
    ///   - model: The name of the model to fine-tune. See https://platform.openai.com/docs/guides/fine-tuning/what-models-can-be-fine-tuned for supported models
    ///   - trainingFileID: The ID of an uploaded file that contains training data.
    ///            This file should be a JSONL file containing prompt-completion pairs for training. The purposes of the file should be set to .fineTune.
    ///   - hyperparameters: Optional. The hyperparameters used for the fine-tuning job.
    ///            This allows customization of the learning process. If not provided, default values will be used.
    ///   - suffix: Optional. A string of up to 18 characters that will be added to your fine-tuned model name.
    ///            For example, a suffix of "custom-model-name" would produce a model name like
    ///            ft:gpt-3.5-turbo:openai:custom-model-name:7p4lURel.
    ///   - validationFileID: Optional. The ID of an uploaded file that contains validation data.
    ///            If provided, this data is used to generate validation metrics periodically during fine-tuning.
    ///            These metrics can be viewed in the fine-tuning results file. The same data should not be present
    ///            in both train and validation files. This file should also be a JSONL file.
    ///   - integrations: Optional. A list of integrations to enable for your fine-tuning job.
    ///            This allows the job to interact with other services or platforms.
    ///   - seed: Optional. The seed controls the reproducibility of the job. Passing in the same seed and job
    ///           parameters should produce the same results, but may differ in rare cases. If a seed is not
    ///           specified, one will be generated for you.
    /// - Returns: An instance of `OpenAI.FineTuning.Job` representing the created fine-tuning job.
    /// - Throws: An error if the API request fails or if there's an issue with the provided parameters.
    public func createFineTuningJob(
        model: OpenAI.Model.Chat,
        trainingFileID: String,
        hyperparameters: OpenAI.FineTuning.Hyperparameters?,
        suffix: String?,
        validationFileID: String?,
        integrations: [OpenAI.FineTuning.Integration]?,
        seed: Int?
    ) async throws -> OpenAI.FineTuning.Job {
        
        let request = OpenAI.APISpecification.RequestBodies.CreateFineTuningJob(
            model: model,
            trainingFileID: trainingFileID,
            hyperparameters: hyperparameters,
            suffix: suffix,
            validationFileID: validationFileID,
            integrations: integrations,
            seed: seed
        )
        
        let job = try await run(\.createFineTuningJob, with: request)
        
        return job
    }
    
    /// - Parameters:
    ///   - after: Optional. Identifier for the last job from the previous pagination request.
    ///   - limit: Optional. Number of fine-tuning jobs to retrieve. Defaults to 20
    public func getFineTuningJobs(
        after jobID: String?,
        limit: Int?
    ) async throws -> OpenAI.FineTuning.Jobs {
        let request = OpenAI.APISpecification.RequestBodies.GetFineTuningJobs(after: jobID, limit: limit)
        
        let jobs = try await run(\.getFineTuningJobs, with: request)
        
        return jobs
    }
    
    public func getFineTuningJob(
        _ jobID: String
    ) async throws -> OpenAI.FineTuning.Job {
        
        let job = try await run(\.getFineTuningJob, with: jobID)
        
        return job
    }
    
    public func cancelFineTuningJob(
        _ jobID: String
    ) async throws -> OpenAI.FineTuning.Job {
        
        let job = try await run(\.cancelFineTuningJob, with: jobID)
        
        return job
    }
    
    /// - Parameters:
    ///   - for: The ID of the fine-tuning job to get events for.
    ///   - after: Identifier for the last event from the previous pagination request.
    ///   - limit: Optional. Number of events to retrieve. Defaults to 20
    public func getFineTuningJobEvents(
        for jobID: String,
        after eventID: String?,
        limit: Int?
    ) async throws -> OpenAI.FineTuning.Job.Events {
        let request = OpenAI.APISpecification.RequestBodies.GetFineTuningJobEvents(
            jobID: jobID,
            after: eventID,
            limit: limit
        )
        
        let events = try await run(\.getFineTuningJobEvents, with: request)
        
        return events
    }
    
    /// - Parameters:
    ///   - for: The ID of the fine-tuning job to get checkpoints for.
    ///   - after: Identifier for the last checkpoint ID from the previous pagination request.
    ///   - limit: Number of checkpoints to retrieve.
    public func getFineTuningJobCheckpoints(
        for jobID: String,
        after checkpointID: String?,
        limit: Int?
    ) async throws -> OpenAI.FineTuning.Job.Checkpoints {
        let request = OpenAI.APISpecification.RequestBodies.GetFineTuningJobCheckpoints(
            jobID: jobID,
            after: checkpointID,
            limit: limit
        )
        
        let checkpoints = try await run(\.getFineTuningJobCheckpoints, with: request)
        
        return checkpoints
    }
}
