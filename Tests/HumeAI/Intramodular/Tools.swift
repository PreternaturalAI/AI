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
        let tool = try await client.createTool(
            id: UUID().uuidString,
            name: "Test Tool",
            description: "Test Description",
            configuration: [:]
        )
        let tools = try await client.listTools()
        XCTAssertNotNil(tools)
        try await client.deleteTool(id: tool.id)
    }
    
    func testCreateTool() async throws {
        let tool = try await client.createTool(
            id: UUID().uuidString,
            name: "Test Tool",
            description: "Test Description",
            configuration: [:]
        )
        try await client.deleteTool(id: tool.id)
        XCTAssertEqual(tool.name, "get_current_weather")
    }
    
    func testListToolVersions() async throws {
        createToolVersion()
        let toolVersions = try await client.run(\.listToolVersions, with: .init(id: "123"))
        XCTAssertNotNil(toolVersions)
    }
    
    func createToolVersion() async throws -> HumeAI.ToolVersion {
        let tool = try await client.createTool(
            id: UUID().uuidString,
            name: "Test Tool",
            description: "Test Description",
            configuration: [:]
        )
        
        let parameters: [String: Any] = [
            "type": "object",
            "properties": [
                "location": [
                    "type": "string",
                    "description": "The city and state, e.g. San Francisco, CA"
                ],
                "format": [
                    "type": "string",
                    "enum": ["celsius", "fahrenheit"],
                    "description": "The temperature unit to use. Infer this from the users location."
                ]
            ],
            "required": ["location", "format"]
        ]
        
        let jsonParameters = try JSONSerialization.data(withJSONObject: parameters)
        let parametersString = String(data: jsonParameters, encoding: .utf8) ?? "{}"

        let toolVersion = try await client.run(
            \.createToolVersion,
             with: .init(
                id: tool.id,
                name: "get_current_weather",
                parameters: parametersString,
                versionDescription: "Fetches current weather and uses celsius or fahrenheit based on location of user.",
                description: "This tool is for getting the current weather.",
                fallbackContent: "Unable to fetch current weather."
             )
        )
    }
    
    func testCreateToolVersion() async throws {
        createToolVersion()
        try await client.deleteTool(id: tool.id)
    }
    
    func testDeleteTool() async throws {
        let tool = try await client.createTool(
            id: UUID().uuidString,
            name: "Test Tool",
            description: "Test Description",
            configuration: [:]
        )
        try await client.deleteTool(id: tool.id)
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
