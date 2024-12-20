//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Perplexity
import XCTest

final class CompletionTests: XCTestCase {
    
    let llm: any LLMRequestHandling = client
        
    func testChatCompletionsLlama3SonarSmall32kChat() async throws {
        let result = try await resultForModel(Perplexity.Model.llamaSonarSmall128kOnline)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsLlama3SonarSmall32kOnline() async throws {
        let result = try await resultForModel(Perplexity.Model.llamaSonarSmall128kOnline)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsLlama3SonarLarge32kChat() async throws {
        let result = try await resultForModel(Perplexity.Model.llamaSonarSmall128kOnline)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsLlama3SonarLarge32kOnline() async throws {
        let result = try await resultForModel(Perplexity.Model.llamaSonarSmall128kOnline)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsLlama38bInstruct() async throws {
        let result = try await resultForModel(Perplexity.Model.llamaSonarSmall128kOnline)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsLlama370bInstruct() async throws {
        let result = try await resultForModel(Perplexity.Model.llamaSonarSmall128kOnline)
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testChatCompletionsMixtral8x7bInstruct() async throws {
        let result = try await resultForModel(Perplexity.Model.llamaSonarSmall128kOnline)
        print(result) // "Hello! How can I assist you today?"
    }
    
    private func resultForModel(_ model: Perplexity.Model) async throws -> String {
        
        let messages: [AbstractLLM.ChatMessage] = [
            AbstractLLM.ChatMessage(
                role: .system,
                body: "You are an extremely intelligent assistant."
            ),
            AbstractLLM.ChatMessage(
                role: .user,
                body: "Sup?"
            ),
        ]
        AbstractLLM.ChatCompletionStream
        
        let result: String = try await llm.complete(
            messages,
            model: model,
            as: String.self
        )
        
        return result
    }
}
