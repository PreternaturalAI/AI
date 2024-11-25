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
    public func listTools() async throws -> [HumeAI.APISpecification.ResponseBodies.Tool] {
        let response = try await run(\.listTools)
        return response.tools
    }
    
    public func createTool(
        name: String,
        description: String?,
        configuration: [String: String]
    ) async throws -> HumeAI.APISpecification.ResponseBodies.Tool {
        let input = HumeAI.APISpecification.RequestBodies.CreateToolInput(
            name: name,
            description: description,
            configuration: .init(parameters: configuration)
        )
        return try await run(\.createTool, with: input)
    }
    
    public func deleteTool(id: String) async throws {
        try await run(\.deleteTool, with: id)
    }
    
    public func updateToolName(id: String, name: String) async throws -> HumeAI.APISpecification.ResponseBodies.Tool {
        let input = HumeAI.APISpecification.RequestBodies.UpdateToolNameInput(name: name)
        return try await run(\.updateToolName, with: input)
    }
}
