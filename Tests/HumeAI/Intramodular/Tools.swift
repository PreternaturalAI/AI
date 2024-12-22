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
        let tool = try await createTool()
        let tools = try await client.listTools()
        XCTAssertNotNil(tools)
        try await client.deleteTool(id: tool.id)
    }
    
    func testCreateTool() async throws {
        let tool = try await createTool()
        try await client.deleteTool(id: tool.id)
        XCTAssertEqual(tool.name, "get_current_weather")
    }
    
    func testListToolVersions() async throws {
        let toolVersion = try await createToolVersion()
        let toolVersions = try await client.run(\.listToolVersions, with: .init(id: toolVersion.tool.id))
        try await client.deleteTool(id: toolVersion.tool.id)
        XCTAssertNotNil(toolVersions)
    }
    
    func testCreateToolVersion() async throws {
        let toolVersion = try await createToolVersion()
        try await client.deleteTool(id: toolVersion.toolVersion.id)
    }
    
    func testDeleteTool() async throws {
        let tool = try await createTool()
        try await client.deleteTool(id: tool.id)
    }
    
    func testUpdateToolName() async throws {
        let tool = try await createTool()
        try await client.updateToolName(id: tool.id, name: "Updated_Name")
        try await client.deleteTool(id: tool.id)
    }
    
    func testGetToolVersion() async throws {
        let toolVersion = try await createToolVersion()
        let updatedTool = try await client.run(
            \.getToolVersion,
             with: .init(
                id: toolVersion.tool.id,
                version: toolVersion.toolVersion.version
             )
        )
        try await client.deleteTool(id: updatedTool.id)
    }
    
    func testDeleteToolVersion() async throws {
        let toolVersion = try await createToolVersion()
        try await client.deleteToolVersion(
            id: toolVersion.tool.id,
            version: toolVersion.toolVersion.version
        )
        try await client.deleteTool(id: toolVersion.tool.id)
    }
    
    func testUpdateToolDescription() async throws {
        let toolVersion = try await createToolVersion()
        try await client.run(
            \.updateToolDescription,
             with: .init(
                id: toolVersion.tool.id,
                version: toolVersion.toolVersion.version,
                description: "Updated Description"
             )
        )
        try await client.deleteTool(id: toolVersion.tool.id)
    }
    
    func createTool() async throws -> HumeAI.Tool {
        let tool = try await client.createTool(
            id: UUID().uuidString,
            name: "Test Tool",
            description: "Test Description",
            configuration: [:]
        )
        
        return tool
    }
    
    
    func createToolVersion() async throws -> (tool: HumeAI.Tool, toolVersion: HumeAI.Tool.ToolVersion) {
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
        
        return (tool, toolVersion)
    }
    
}
