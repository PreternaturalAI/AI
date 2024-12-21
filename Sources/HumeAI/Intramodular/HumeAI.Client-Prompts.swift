//
// Copyright (c) Preternatural AI, Inc.
//

import Merge
import NetworkKit
import SwiftAPI

extension HumeAI.Client {
    public func listPrompts() async throws -> [HumeAI.Prompt] {
        let response = try await run(\.listPrompts)
        
        return response.promptsPage
    }
    
    public func createPrompt(
        name: String,
        text: String,
        description: String? = nil
    ) async throws -> HumeAI.Prompt {
        let input = HumeAI.APISpecification.RequestBodies.CreatePromptInput(
            name: name,
            text: text,
            versionDescription: description
        )
        
        return try await run(\.createPrompt, with: input)
    }
    
    public func deletePrompt(id: String) async throws {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        try await run(\.deletePrompt, with: input)
    }
    
    public func listPromptVersions(id: String) async throws -> [HumeAI.Prompt] {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        
        return try await run(\.listPromptVersions, with: input).promptsPage
    }
    
    public func createPromptVersion(
        id: String,
        text: String,
        versionDescription: String? = nil
    ) async throws -> HumeAI.Prompt.PromptVersion {
        let input = HumeAI.APISpecification.RequestBodies.CreatePromptVersionInput(
            id: id,
            text: text,
            versionDescription: versionDescription
        )
        
        return try await run(\.createPromptVersion, with: input)
    }
    
    public func getPromptVersion(
        id: String,
        version: Int
    ) async throws -> HumeAI.Prompt.PromptVersion {
        let input = HumeAI.APISpecification.PathInput.IDWithVersion(
            id: id,
            version: version
        )
        
        return try await run(\.getPromptVersion, with: input)
    }
    
    public func deletePromptVersion(
        id: String,
        version: Int
    ) async throws {
        let input = HumeAI.APISpecification.PathInput.IDWithVersion(
            id: id,
            version: version
        )
        try await run(\.deletePromptVersion, with: input)
    }
    
    public func updatePromptName(
        id: String,
        name: String
    ) async throws {
        let input = HumeAI.APISpecification.RequestBodies.UpdatePromptNameInput(
            id: id,
            name: name
        )
        try await run(\.updatePromptName, with: input)
    }
    
    public func updatePromptDescription(
        id: String,
        version: Int,
        description: String
    ) async throws {
        let input = HumeAI.APISpecification.RequestBodies.UpdatePromptDescriptionInput(
            id: id,
            version: version,
            description: description
        )
        
        return try await run(\.updatePromptDescription, with: input)
    }
}
