//
//  Dataset.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientDatasetTests: XCTestCase {
    
    func testListDatasets() async throws {
        let datasets = try await client.listDatasets()
        XCTAssertNotNil(datasets)
    }
    
    func testCreateDataset() async throws {
        let dataset = try await client.createDataset(name: "Test Dataset", description: "Test Description", fileIds: ["test-id"])
        XCTAssertNotNil(dataset)
    }
    
    func testDeleteDataset() async throws {
        try await client.deleteDataset(id: "test-id")
    }
    
    func testGetDataset() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testCreateDatasetVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testListDatasetVersions() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testListDatasetFiles() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetDatasetVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testListDatasetVersionFiles() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
