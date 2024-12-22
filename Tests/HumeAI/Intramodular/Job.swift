//
//  Job.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientJobTests: XCTestCase {
    
    // MARK: - Inference Jobs
    func testStartInferenceJob() async throws {
        
        let response = try await client.startInferenceJob(
            urls: [URL(string:"https://hume-tutorials.s3.amazonaws.com/faces.zip")!],
            models: .burst()
        )
        
        // Test JobResponse structure
        XCTAssertNotNil(response)
    }
    
    // MARK: - Job Status and Progress
    func testGetJobDetails() async throws {
        let response = try await client.getJobDetails(id: "test-id")
        
        // Test timestamps
        XCTAssertGreaterThan(response.state.endedTimestampMs, response.state.startedTimestampMs)
        XCTAssertGreaterThan(response.state.endedTimestampMs, response.state.createdTimestampMs)
        
        // Test status
        XCTAssertEqual(response.state.status, "COMPLETED")
        
        // Test request data
        XCTAssertNotNil(response.request.urls)
        XCTAssertFalse(response.request.notify)
    }
    
    // MARK: - Job Predictions
    func testGetJobPredictions() async throws {
        let predictions = try await client.getJobPredictions(id: "test-id")
        
        guard let firstPrediction = predictions.first else {
            XCTFail("No predictions found")
            return
        }
        
        // Test source
        XCTAssertEqual(firstPrediction.source.type, "url")
        XCTAssertNotNil(firstPrediction.source.url)
        
        // Test results structure
        XCTAssertNotNil(firstPrediction.results.predictions)
        XCTAssertTrue(firstPrediction.results.errors.isEmpty)
        
        // Test face predictions
        if let facePrediction = firstPrediction.results.predictions.first?.models.face?.groupedPredictions.first?.predictions.first {
            // Test bounding box
            XCTAssertGreaterThan(facePrediction.prob, 0)
            XCTAssertNotNil(facePrediction.box)
            
            // Test emotions
            XCTAssertFalse(facePrediction.emotions.isEmpty)
            
            // Test specific emotions exist
            let emotionNames = facePrediction.emotions.map { $0.name }
            XCTAssertTrue(emotionNames.contains("Joy"))
            XCTAssertTrue(emotionNames.contains("Fear"))
            
            // Test emotion scores
            for emotion in facePrediction.emotions {
                XCTAssertGreaterThanOrEqual(emotion.score, 0)
                XCTAssertLessThanOrEqual(emotion.score, 1)
            }
        } else {
            XCTFail("No face predictions found")
        }
    }
    
    // MARK: - Error Cases
    func testInvalidJobId() async throws {
        do {
            _ = try await client.getJobDetails(id: "invalid-id")
            XCTFail("Expected error for invalid job ID")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    func testInvalidFileUrl() async throws {
        do {
            _ = try await client.startInferenceJob(
                urls: [URL(string:"https://hume-tutorials.s3.amazonaws.com/faces.zip")!],
                models: .burst()
            )
            XCTFail("Expected error for invalid file URL")
        } catch {
            XCTAssertNotNil(error)
        }
    }
    
    // MARK: - Helper Methods
    func testGetTopEmotions() async throws {
        let predictions = try await client.getJobPredictions(id: "test-id")
        
        guard let facePrediction = predictions.first?.results.predictions.first?.models.face?.groupedPredictions.first?.predictions.first else {
            XCTFail("No face predictions found")
            return
        }
        
        // Get top 3 emotions
        let topEmotions = facePrediction.emotions
            .sorted { $0.score > $1.score }
            .prefix(3)
        
        XCTAssertEqual(topEmotions.count, 3)
        
        // Verify they're actually the highest scores
        let highestScore = topEmotions.first!.score
        for emotion in facePrediction.emotions {
            if emotion.name != topEmotions.first!.name {
                XCTAssertLessThanOrEqual(emotion.score, highestScore)
            }
        }
    }
}
