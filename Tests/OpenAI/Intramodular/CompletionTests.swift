//
// Copyright (c) Vatsal Manot
//

import FoundationX
import LargeLanguageModels
import OpenAI
import XCTest

final class CompletionTests: XCTestCase {
    func testCreateEmbeddings() async throws {
        let result = try await client.createEmbeddings(
            model: .ada,
            for: ["An Amazon review with a positive sentiment."]
        )
        
        _ = result
    }
    
    /*func testTextCompletions() async throws {
        let result = try await client.createCompletion(
            model: .instructGPT(.davinci),
            prompt: """
Correct this to standard English:

She no went to the market.
""",
            parameters: .init(maxTokens: 60, topProbabilityMass: 1)
        )
        
        _ = result
    }*/
    
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
            model: OpenAI.Model.chat(.gpt_4),
            as: .string
        )
        
        print(result) // "Hello! How can I assist you today?"
    }
    
    func testGPTVisionTurbo() async throws {
        let url: URL = try await Base64DataURL(imageURL: URL(string: "https://upload.wikimedia.org/wikipedia/en/7/77/EricCartman.png")!).url
        
        let result = try await client.createChatCompletion(
            messages: [
                OpenAI.ChatMessage(
                    role: .system,
                    body: "You are an extremely intelligent assistant."
                ),
                OpenAI.ChatMessage(
                    role: .user,
                    body: .content([
                        .text("Who is this?"),
                        .imageURL(url)
                    ])
                ),                
            ],
            model: .chat(.gpt_4_vision_preview),
            parameters: .init()
        )
        
        print(result.choices)
    }
}
