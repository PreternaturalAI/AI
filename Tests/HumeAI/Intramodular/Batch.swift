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
            files: [.init(
                url: "test-url",
                mimeType: "test/mime"
            )],
            models: [.burst]
        )
        XCTAssertNotNil(job)
    }
    
    func testGetJobDetails() async throws {
        let job = try await client.getJobDetails(id: "test-id")
        XCTAssertNotNil(job)
    }
    
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
}
