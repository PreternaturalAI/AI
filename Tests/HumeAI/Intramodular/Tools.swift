//
//  Tools.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientToolTests: XCTestCase {
    
    func testListTools() async throws {
        let tools = try await client.listTools()
        XCTAssertNotNil(tools)
    }
    
    func testCreateTool() async throws {
        let tool = try await client.createTool(id: "test-id", name: "Test Tool", description: "Test Description", configuration: ["key": "value"])
        XCTAssertEqual(tool.name, "Test Tool")
    }
    
    func testListToolVersions() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testCreateToolVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testDeleteTool() async throws {
        try await client.deleteTool(id: "test-id")
    }
    
    func testUpdateToolName() async throws {
        let tool = try await client.updateToolName(id: "test-id", name: "Updated Name")
        XCTAssertEqual(tool.name, "Updated Name")
    }
    
    func testGetToolVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testDeleteToolVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdateToolDescription() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
