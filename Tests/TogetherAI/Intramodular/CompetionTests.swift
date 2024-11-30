//
// Copyright (c) Vatsal Manot
//

import Foundation
import LargeLanguageModels
import TogetherAI
import XCTest

final class CompletionTests: XCTestCase {
    
    func testCompletionsLLMRequest() async throws {
        let llm: any LLMRequestHandling = client
        
        let prompt: AbstractLLM.TextPrompt = .init(stringLiteral: "List all of the states in the USA and their capitals in a table.")
        let parameters: AbstractLLM.TextCompletionParameters = .init(
            tokenLimit: .fixed(400),
            temperature: 0.8,
            stops: nil
        )
        
        let completion = try await llm.complete(
            prompt: prompt,
            parameters: parameters
        )
        
        print(completion)
    }
    
    func testCompletionsLlama() async throws {
        let completion = try await client
            .createCompletion(
                for: .llama2_70B,
                prompt: "List all of the states in the USA and their capitals in a table.",
                maxTokens: 200,
                temperature: 0.7,
                choices: 5
            )
        print(completion)
    }
    
    func testCompletionsMistral() async throws {
        let completion = try await client
            .createCompletion(
                for: .mistral7b,
                prompt: "List all of the states in the USA and their capitals in a table.",
                maxTokens: 400,
                temperature: 0.5,
                choices: 2
            )
        print(completion)
    }
    
    func testCompletionsMixtral() async throws {
        let completion = try await client
            .createCompletion(
                for: .mixtral8x7b,
                prompt: "List all of the states in the USA and their capitals in a table.",
                maxTokens: 175,
                temperature: 0.9,
                choices: 3
            )
        print(completion)
    }
}


