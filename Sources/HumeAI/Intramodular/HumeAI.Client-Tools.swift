//
//  HumeAI.Client-Tools.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listTools() async throws -> [HumeAI.Tool] {
        let response = try await run(\.listTools)
        return response.toolsPage
    }
    
    public func createTool(
        id: String,
        name: String,
        description: String?,
        configuration: [String: String]
    ) async throws -> HumeAI.Tool {
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

        let tool = HumeAI.APISpecification.RequestBodies.CreateToolInput(
            name: "get_current_weather",
            parameters: parametersString,
            versionDescription: "Fetches current weather and uses celsius or fahrenheit based on location of user.",
            description: "This tool is for getting the current weather.",
            fallbackContent: "Unable to fetch current weather."
        )
        return try await run(\.createTool, with: tool)
    }
    
    public func deleteTool(
        id: String
    ) async throws {
        
        let input = HumeAI.APISpecification.PathInput.ID(id: id)
        
        try await run(\.deleteTool, with: input)
    }
    
    public func deleteToolVersion(
        id: String,
        version: Int
    ) async throws {
        
        let input = HumeAI.APISpecification.PathInput.IDWithVersion(
            id: id,
            version: version
        )
        
        try await run(\.deleteToolVersion, with: input)
    }
    
    public func updateToolName(
        id: String,
        name: String
    ) async throws {
        let input = HumeAI.APISpecification.RequestBodies.UpdateToolNameInput(
            id: id,
            name: name
        )
        try await run(\.updateToolName, with: input)
    }
}
