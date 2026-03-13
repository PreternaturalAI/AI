

import LargeLanguageModels
import xAI
import XCTest

final class CompletionTests: XCTestCase {
    
    let llm: any LLMRequestHandling = client
    
    func testChatCompletionsGrokBeta() async throws {
        let result = try await resultForModel(xAI.Model.grok_beta)
        print(result) // "Hey! What's up with you?"
    }
    
    func testChatCompletionsGrokVisionBeta() async throws {
        let result = try await resultForModel(xAI.Model.grok_vision_beta)
        print(result) // "Hey! How can I help you today?"
    }
    
    private func resultForModel(_ model: xAI.Model) async throws -> String {
        
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

