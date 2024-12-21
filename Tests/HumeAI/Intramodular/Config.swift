//
// Copyright (c) Preternatural AI, Inc.
//

@testable import HumeAI
import XCTest

final class HumeAIClientConfigTests: XCTestCase {
    
    func testListConfigs() async throws {
        let configs = try await client.listConfigs()
        XCTAssertNotNil(configs)
    }
    
    func testCreateConfig() async throws {
        let config = try await client.createConfig(name: "Test Config", description: "Test Description", settings: ["key": "value"])
        XCTAssertEqual(config.name, "Test Config")
    }
    
    func testDeleteConfig() async throws {
        try await client.deleteConfig(id: "test-id")
    }
    
    func testListConfigVersions() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testCreateConfigVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetConfigVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testDeleteConfigVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdateConfigName() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdateConfigDescription() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
