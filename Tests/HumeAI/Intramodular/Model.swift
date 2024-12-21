//
// Copyright (c) Preternatural AI, Inc.
//

@testable import HumeAI
import XCTest

final class HumeAIClientModelTests: XCTestCase {
    
    func testListModels() async throws {
        let models = try await client.listModels()
        XCTAssertNotNil(models)
        
        if let model = models.first {
            XCTAssertNotNil(model.id)
            XCTAssertNotNil(model.name)
            XCTAssertNotNil(model.latestVersion)
        }
    }
    
    func testGetModel() async throws {
        let model = try await client.getModel(id: "test-id")
        XCTAssertNotNil(model)
        XCTAssertNotNil(model.latestVersion)
    }
    
    func testUpdateModelName() async throws {
        let model = try await client.updateModelName(
            id: "test-id",
            name: "Updated Name"
        )
    }
    
    func testListModelVersions() async throws {
        let versions = try await client.listModelVersions(id: "test-id")
        XCTAssertNotNil(versions)
        
        if let version = versions.first {
            XCTAssertNotNil(version.id)
            XCTAssertNotNil(version.modelId)
            XCTAssertNotNil(version.version)
        }
    }
    
    func testGetModelVersion() async throws {
        let version = try await client.getModelVersion(
            id: "test-id",
            version: 1
        )
        XCTAssertNotNil(version)
        XCTAssertNotNil(version.modelId)
    }
    
    func testUpdateModelDescription() async throws {
        let version = try await client.updateModelDescription(
            id: "test-id",
            versionId: "version-id",
            description: "Updated Description"
        )
    }
}
