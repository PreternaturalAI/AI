//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import OpenAI
import XCTest

final class FineTuningTests: XCTestCase {
    
    func testCreateFineTuningJob() async throws {
        // note: add your own training file id here
        let trainingFileID = "file-Ja8LgV6NTfusyMlNWPQYSMXb"
        let hyperparameters = OpenAI.FineTuning.Hyperparameters(
            batchSize: .auto,
            learningRateMultiplier: .auto,
            nEpochs: .auto
        )
        let suffix = "myTestJob"
        
        do {
            let job: OpenAI.FineTuning.Job = try await client.createFineTuningJob(
                model: .gpt_3_5_turbo,
                trainingFileID: trainingFileID,
                hyperparameters: hyperparameters,
                suffix: suffix,
                validationFileID: nil,
                integrations: nil,
                seed: nil
            )
            print(job)
            // cancel job
            let _ = try await client.cancelFineTuningJob(job.id.rawValue)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func testGetFineTurningJobs() async throws {
        do {
            let jobs: OpenAI.FineTuning.Jobs = try await client.getFineTuningJobs(after: nil, limit: nil)
            print(jobs)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func testGetFineTurningJob() async throws {
        // note: change the jobID to your relevant jobs
        let jobID = "ftjob-ICikHc9b3oV20CpsFV0QL1Cp"
        do {
            let job: OpenAI.FineTuning.Job = try await client.getFineTuningJob(jobID)
            print(job)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func testCancelFineTurningJob() async throws {
        // note: add your own training file id here
        let trainingFileID = "file-OrMNeQshcJ2qO3CDbYMZY8x1"
        do {
            let job: OpenAI.FineTuning.Job = try await client.createFineTuningJob(
                model: .gpt_3_5_turbo,
                trainingFileID: trainingFileID,
                hyperparameters: nil,
                suffix: nil,
                validationFileID: nil,
                integrations: nil,
                seed: nil
            )
            
            let cancelledJob: OpenAI.FineTuning.Job = try await client.cancelFineTuningJob(job.id.rawValue)
            print(cancelledJob)
            XCTAssertTrue(cancelledJob.status == .cancelled)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func testGetFineTurningJobEvents() async throws {
        // note: change the jobID to your relevant jobs
        let jobID = "ftjob-w5Abod7qBZ1VbqhVNlaTnc05"
        do {
            let jobs: OpenAI.FineTuning.Job.Events = try await client.getFineTuningJobEvents(for: jobID, after: nil, limit: nil)
            print(jobs)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func testGetFineTurningJobCheckpoints() async throws {
        // note: change the jobID to your relevant jobs
        let jobID = "ftjob-ICikHc9b3oV20CpsFV0QL1Cp"
        do {
            let jobs: OpenAI.FineTuning.Job.Checkpoints = try await client.getFineTuningJobCheckpoints(for: jobID, after: nil, limit: nil)
            print(jobs)
        } catch {
            XCTFail(String(describing: error))
        }
    }
}
