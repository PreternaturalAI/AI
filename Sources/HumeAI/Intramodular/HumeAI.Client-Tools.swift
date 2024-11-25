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
        return response.tools
    }
    
    public func createTool(
        id: String,
        name: String,
        description: String?,
        configuration: [String: String]
    ) async throws -> HumeAI.Tool {
        let input = HumeAI.APISpecification.RequestBodies.CreateToolInput(
            id: id,
            name: name,
            description: description,
            configuration: .init(parameters: configuration)
        )
        return try await run(\.createTool, with: input)
    }
    
    public func deleteTool(
        id: String
    ) async throws {
        
        let input = HumeAI.APISpecification.PathInput.ID(id: id)
        
        try await run(\.deleteTool, with: input)
    }
    
    public func updateToolName(
        id: String,
        name: String
    ) async throws -> HumeAI.Tool {
        let input = HumeAI.APISpecification.RequestBodies.UpdateToolNameInput(
            id: id,
            name: name
        )
        return try await run(\.updateToolName, with: input)
    }
}
