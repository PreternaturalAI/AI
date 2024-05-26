//
// Copyright (c) Vatsal Manot
//

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
        let url = try await downloadAndEncodeImage(from: "https://upload.wikimedia.org/wikipedia/en/7/77/EricCartman.png")
        
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

fileprivate func downloadAndEncodeImage(
    from urlString: String
) async throws -> URL {
    guard let url = URL(string: urlString) else {
        throw URLError(.badURL)
    }
    
    // Using async/await to download data
    let (data, _) = try await URLSession.shared.data(from: url)
    
    let base64String = data.base64EncodedString()
    let result = URL(string: "data:image/jpeg;base64,\(base64String)")!
    
    return result
}
