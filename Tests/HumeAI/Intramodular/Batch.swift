//
//  Batch.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientBatchTests: XCTestCase {
    func testStartInferenceJob() async throws {
        let job = try await client.startInferenceJob(
            urls: [URL(string: "https://hume-tutorials.s3.amazonaws.com/faces.zip")!],
            models: .burst()
        )
        XCTAssertNotNil(job)
    }
    
    func testGetJobDetails() async throws {
        let job = try await client.getJobDetails(id: "424ddd20-b604-435b-abb0-712f1fe9303b")
        XCTAssertNotNil(job)
    }
    
    func testListJobs() async throws {
        let jobs = try await client.listJobs()
        XCTAssertNotNil(jobs)
    }
    
    func testGetJobPredictions() async throws {
        let predictions = try await client.getJobPredictions(id: "424ddd20-b604-435b-abb0-712f1fe9303b")
        XCTAssertNotNil(predictions)
    }
    
    func testGetJobArtifacts() async throws {
        //Get the artifacts ZIP of a completed inference job.
        
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
