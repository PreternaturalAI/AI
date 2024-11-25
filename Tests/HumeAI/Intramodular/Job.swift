//
//  Job.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientJobTests: XCTestCase {
    
    // Training Jobs
    func testStartTrainingJob() async throws {
        let job = try await client.startTrainingJob(
            datasetId: "test-id",
            name: "Test Training Job",
            description: "Test Description",
            configuration: ["key": "value"]
        )
        XCTAssertNotNil(job)
        XCTAssertEqual(job.status, "pending") // Assuming initial status is pending
        XCTAssertNotNil(job.id)
    }
    
    func testStartTrainingJobWithoutDescription() async throws {
        let job = try await client.startTrainingJob(
            datasetId: "test-id",
            name: "Test Training Job",
            configuration: ["key": "value"]
        )
        XCTAssertNotNil(job)
    }
    
    // Custom Inference Jobs
    func testStartCustomInferenceJob() async throws {
        let files = [
            HumeAI.FileInput(
                url: "test-url",
                mimeType: "test/mime",
                metadata: ["key": "value"]
            )
        ]
        
        let job = try await client.startCustomInferenceJob(
            modelId: "test-id",
            files: files,
            configuration: ["key": "value"]
        )
        XCTAssertNotNil(job)
        XCTAssertNotNil(job.id)
    }
    
    // Job Status and Progress
    func testGetJobDetails() async throws {
        let job = try await client.getJobDetails(id: "test-id")
        XCTAssertNotNil(job)
        XCTAssertNotNil(job.status)
        XCTAssertNotNil(job.createdOn)
        XCTAssertNotNil(job.modifiedOn)
    }
    
    // Error Cases
    func testStartTrainingJobWithInvalidDataset() async throws {
        do {
            _ = try await client.startTrainingJob(
                datasetId: "invalid-id",
                name: "Test Job",
                configuration: ["key": "value"]
            )
            XCTFail("Expected error for invalid dataset ID")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    func testStartCustomInferenceJobWithInvalidModel() async throws {
        do {
            _ = try await client.startCustomInferenceJob(
                modelId: "invalid-id",
                files: [.init(url: "test-url", mimeType: "test/mime")],
                configuration: ["key": "value"]
            )
            XCTFail("Expected error for invalid model ID")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    func testGetInvalidJobDetails() async throws {
        do {
            _ = try await client.getJobDetails(id: "invalid-id")
            XCTFail("Expected error for invalid job ID")
        } catch {
            // Expected error
            XCTAssertNotNil(error)
        }
    }
    
    // Job Results
    func testJobPredictions() async throws {
        let job = try await client.getJobDetails(id: "test-id")
        
        if let predictions = job.predictions {
            for prediction in predictions {
                // Validate file info
                XCTAssertNotNil(prediction.file.url)
                XCTAssertNotNil(prediction.file.mimeType)
                
                // Validate results
                XCTAssertFalse(prediction.results.isEmpty)
                for result in prediction.results {
                    XCTAssertNotNil(result.model)
                    XCTAssertNotNil(result.results)
                }
            }
        }
    }
    
    // Job Artifacts
    func testJobArtifacts() async throws {
        let job = try await client.getJobDetails(id: "test-id")
        
        if let artifacts = job.artifacts {
            XCTAssertFalse(artifacts.isEmpty)
        }
    }
    
    // Unimplemented Methods Tests
    func testListJobs() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetJobPredictions() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetJobArtifacts() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testStartInferenceJobFromLocalFile() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    // Job Status Transitions
    func testJobStatusTransitions() async throws {
        let job = try await client.getJobDetails(id: "test-id")
        
        // Verify status is a valid value
        let validStatuses = ["pending", "running", "completed", "failed"]
        XCTAssertTrue(validStatuses.contains(job.status))
    }
    
    // Validation Tests
    func testJobTimestamps() async throws {
        let job = try await client.getJobDetails(id: "test-id")
        
        // Created timestamp should be before or equal to modified timestamp
        XCTAssertLessThanOrEqual(job.createdOn, job.modifiedOn)
    }
}
