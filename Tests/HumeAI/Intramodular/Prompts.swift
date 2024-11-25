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
        XCTAssertNotNil(prompts)
    }
    
    func testCreatePrompt() async throws {
        let prompt = try await client.createPrompt(name: "Test Prompt", content: "Test Content", description: "Test Description")
        XCTAssertEqual(prompt.name, "Test Prompt")
    }
    
    func testDeletePrompt() async throws {
        try await client.deletePrompt(id: "test-id")
    }
    
    func testListPromptVersions() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testCreatePromptVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testGetPromptVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testDeletePromptVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdatePromptName() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdatePromptDescription() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
