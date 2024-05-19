//
// Copyright (c) Vatsal Manot
//

import Anthropic
import LargeLanguageModels
import XCTest

final class AnthropicTests: XCTestCase {    
    func test() async throws {
        let completion = try await client.complete(
            prompt: .chat([
                .user("What's up?"),
                .assistant("Not much, just chatting with you!"),
                .user("That's cool"),
            ]),
            parameters: AbstractLLM.ChatCompletionParameters()
        )
        
        print(completion)
    }
    
    func testSwiftUICodeGen() async throws {
        let completion = try await client.complete(
            generateSwiftUICode(requirement: "a message list view styled like Apple's iMessages"),
            model: Anthropic.Model.claude_3_haiku_20240307
        )
        
        print(completion)
    }
}

func generateSwiftUICode(requirement: PromptLiteral) -> [AbstractLLM.ChatMessage] {
    let systemPrompt = "Act as a staff iOS engineer, specializing in SwiftUI and prototyping, capable of creating SwiftUI components and code from provided design descriptions. Only provide code."
    
    let userPrompt: PromptLiteral =
     """
      Develop a functional, production-ready prototype in SwiftUI according to design requirements defined within XML tags.
    
      Ensure your code is error-free and ready for compilation at all times..
    
      Structure the code for seamless integration into an existing project, ensuring that all variables, views, and data models are appropriately defined, including sample data if necessary.
    
      Include necessary imports and ensure the code is compatible with the latest version of SwiftUI.
    
      Ensure the code adheres to Swift best practices for readability, as well as SwiftUI best practices for optimal performance and maintainability
    
      Test the code snippet using Xcode Preview to enable designers to see the result immediately.
    
      If the design includes images make sure to use SF symbols to populate images as placeholders.
    
      <design_requirement>\(requirement)</design_requirement>
    
    """
    
    return [
        .system(systemPrompt),
        .user(userPrompt),
        .assistant(
            "```swift"
        )
    ]
}

