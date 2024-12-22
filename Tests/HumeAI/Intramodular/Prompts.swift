//
//  Prompts.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientPromptTests: XCTestCase {

    func testListPrompts() async throws {
        let prompts = try await client.listPrompts()
        
        for prompt in prompts {
            try await client.deletePrompt(id: prompt.id)
        }
        
        XCTAssertNotNil(prompts)
    }
    
    func testCreatePrompt() async throws {
        let prompt = try await createPrompt()
        try await client.deletePrompt(id: prompt.id)
        XCTAssertNotNil(prompt)
    }
    
    func testListPromptVersions() async throws {
        let prompt = try await createPromptVersion()
        let versions = try await client.listPromptVersions(id: prompt.prompt.id)
        print("VERSIONS", versions)
        try await client.deletePrompt(id: prompt.prompt.id)
        XCTAssertNotNil(versions)
    }
    
    func testGetPromptVersion() async throws {
        let prompt = try await createPromptVersion()
        let promptVersion = try await client.getPromptVersion(
            id: prompt.prompt.id,
            version: 0
        )
        try await client.deletePrompt(id: prompt.prompt.id)
        XCTAssertNotNil(promptVersion)
    }
    
    func testCreatePromptVersion() async throws {
        let prompt = try await createPrompt()

        let promptVersion = try await client.createPromptVersion(
            id: prompt.id,
            text: "<role>Test Content</role>",
            versionDescription: ""
        )
        
        XCTAssertNotNil(promptVersion.id)
        XCTAssertEqual(promptVersion.version, 0)
    }
    
    func testDeletePromptVersion() async throws {
        let prompt = try await createPromptVersion()
        try await client.deletePromptVersion(
            id: prompt.prompt.id,
            version: prompt.promptVersion.version
        )
    }
    
    func testUpdatePromptName() async throws {
        let prompt = try await createPromptVersion()
        try await client.updatePromptName(
            id: prompt.prompt.id,
            name: "Updated name"
        )
        try await client.deletePrompt(id: prompt.prompt.id)
    }
    
    func testUpdatePromptDescription() async throws {
        let promptVersion = try await createPromptVersion()
        try await client.updatePromptDescription(
            id: promptVersion.prompt.id,
            version: promptVersion.promptVersion.version,
            description: "Updated Description"
        )
        let prompts = try await client.listPrompts()
        try await client.deletePrompt(id: promptVersion.prompt.id)
    }
    
    func testDeletePrompt() async throws {
        let prompt = try await createPrompt()
        try await client.deletePrompt(id: prompt.id)
    }
    
    func createPrompt() async throws -> HumeAI.Prompt {
        let prompt = try await client.createPrompt(
            name: "Test Prompt",
            text: "<role>Test Content</role>"
        )
        
        return prompt
    }
    
    func createPromptVersion() async throws -> (prompt: HumeAI.Prompt, promptVersion: HumeAI.Prompt.PromptVersion) {
        let prompt = try await createPrompt()

        let promptVersion = try await client.createPromptVersion(
            id: prompt.id,
            text: "<role>Test Content</role>"
        )
        
        return (prompt, promptVersion)
    }
}
