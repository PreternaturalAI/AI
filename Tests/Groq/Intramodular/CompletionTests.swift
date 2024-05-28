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
    
    let llm: any LLMRequestHandling = client
    
    func testChatCompletionsMixtral8x7b() async throws {
        let result = try await resultForModel(Groq.Model.mixtral_8x7b)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsGemma7b() async throws {
        let result = try await resultForModel(Groq.Model.gemma_7b)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsLlama3_70b() async throws {
        let result = try await resultForModel(Groq.Model.llama3_70b)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsLlama3_8b() async throws {
        let result = try await resultForModel(Groq.Model.llama3_8b)
        print(result) // "Hello! How can I assist you today?"
    }
    
    private func resultForModel(_ model: Groq.Model) async throws -> String {
        
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
            model: model,
            as: String.self
        )
        
        return result
    }
}
