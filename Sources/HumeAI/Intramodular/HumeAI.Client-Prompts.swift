//
//  Untitled.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listPrompts() async throws -> [HumeAI.Prompt] {
        let response = try await run(\.listPrompts)
        return response.prompts
    }
    
    public func createPrompt(
        name: String,
        content: String,
        description: String? = nil
    ) async throws -> HumeAI.Prompt {
        let input = HumeAI.APISpecification.RequestBodies.CreatePromptInput(
            name: name,
            description: description,
            content: content,
            metadata: nil
        )
        return try await run(\.createPrompt, with: input)
    }
    
    public func deletePrompt(id: String) async throws {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        try await run(\.deletePrompt, with: input)
    }
}
