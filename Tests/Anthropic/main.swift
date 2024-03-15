//
// Copyright (c) Vatsal Manot
//

import Anthropic
import LargeLanguageModels
import XCTest

final class AnthropicTests: XCTestCase {
    func test() async throws {
        let api = Anthropic(apiKey: nil)
        
        let completion = try await api.complete(
            prompt: .chat([
                .user("What's up?"),
                .assistant("Not much, just chatting with you!"),
                .user("That's cool"),
            ]),
            parameters: AbstractLLM.ChatCompletionParameters()
        )
        
        print(completion)
    }
}
