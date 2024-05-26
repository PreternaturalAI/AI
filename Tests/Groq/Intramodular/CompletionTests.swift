//
//  File.swift
//
//
//  Created by Natasha Murashev on 5/26/24.
//

import LargeLanguageModels
import Groq
import XCTest

final class CompletionTests: XCTestCase {
    
    func testChatCompletions() async throws {
        let llm: any LLMRequestHandling = client

        let messages: [AbstractLLM.ChatMessage] = [
            AbstractLLM.ChatMessage(
                role: .system,
                body: "You are an extremely intelligent assistant."
            ),
            AbstractLLM.ChatMessage(
                role: .user,
                body: "Sup?"
            )
        ]
        
        let result: String = try await llm.complete(
            messages,
            model: Groq.Model.gemma_7b,
            as: String.self
        )
        
        print(result) // "Hello! How can I assist you today?"
    }
}
