//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import XAI
import XCTest

final class CompletionTests: XCTestCase {
    let llm: any LLMRequestHandling = client
        
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
            model: XAI.Model.grokBeta,
            as: .string
        )
        
        print(result) // "Hello! How can I assist you today?"
    }
}
