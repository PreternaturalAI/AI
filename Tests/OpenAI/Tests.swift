//
// Copyright (c) Vatsal Manot
//

@testable import OpenAI

import XCTest

final class OpenAITests: XCTestCase {    
    private let client = OpenAI.APIClient(apiKey: "xxx")
    
    func testCreateEmbeddings() async throws {
        let result = try await client.createEmbeddings(
            model: .ada,
            for: ["An Amazon review with a positive sentiment."]
        )
        
        _ = result
    }
    
    func testTextCompletions() async throws {
        let result = try await client.createCompletion(
            model: .instructGPT(.davinci),
            prompt: """
Correct this to standard English:

She no went to the market.
""",
            parameters: .init(maxTokens: 60, topProbabilityMass: 1)
        )
        
        _ = result
    }
    
    func testChatCompletions() async throws {        
        let result = try await client.createChatCompletion(
            messages: [
                OpenAI.ChatMessage(
                    role: .system,
                    body: "You are an extremely intelligent assistant."
                ),
                OpenAI.ChatMessage(
                    role: .user,
                    body: "Sup?"
                ),
                OpenAI.ChatMessage(
                    role: .assistant,
                    body: "I'm coming up with a list of things! Here you go:"
                ),
                
            ],
            model: .chat(.gpt_3_5_turbo),
            parameters: .init()
        )
        
        print(result.choices)
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
