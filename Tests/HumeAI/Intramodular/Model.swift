//
//  Model.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientModelTests: XCTestCase {
    
    func testListModels() async throws {
        let models = try await client.listModels()
        XCTAssertNotNil(models)
    }
    
    func testGetModel() async throws {
        let model = try await client.getModel(id: "test-id")
        XCTAssertNotNil(model)
    }
    
    func testUpdateModelName() async throws {
        let model = try await client.updateModelName(id: "test-id", name: "Updated Name")
        XCTAssertNotNil(model)
    }
    
    func testListModelVersions() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetModelVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdateModelDescription() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
