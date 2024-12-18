//
//  _GeminiTests+CodeExecution.swift
//  AI
//
//  Created by Jared Davidson on 12/13/24.
//

import Testing
import Foundation
import _Gemini
import AI

@Suite struct _GeminiCodeExecutionTests {
    @Test func testCodeExecution() async throws {
        let messages = [
            _Gemini.Message(
                role: .user,
                content: "What is the sum of the first 50 prime numbers? Generate and run code for the calculation, and make sure you get all 50."
            )
        ]
        
        let response = try await client.generateContentWithCodeExecution(
            messages: messages,
            model: .gemini_1_5_pro_latest
        )
        
        print("Response:", response)
        
        // Basic response validation
        #expect(!response.text.isEmpty, "Response should not be empty")
        
        // Content structure validation
        let responseText = response.text
        
        // Check for Python code
        let codeBlockExists = responseText.contains("```python") && responseText.contains("```")
        #expect(codeBlockExists, "Response should contain a Python code block")

        // Check for the correct result
        let containsCorrectResult = responseText.contains("5117")
        #expect(containsCorrectResult, "Response should contain the correct sum (5117)")
        
        // Check token usage is present and valid
        let tokenUsage = response.tokenUsage
        #expect(tokenUsage != nil, "Token usage should be present")
        if let usage = tokenUsage {
            #expect(usage.prompt > 0, "Prompt tokens should be greater than 0")
            #expect(usage.response > 0, "Response tokens should be greater than 0")
            #expect(usage.total > 0, "Total tokens should be greater than 0")
            #expect(usage.total == usage.prompt + usage.response, "Total tokens should equal prompt + response")
        }
        
        // Check finish reason
        #expect(response.finishReason == .stop, "Response should have completed normally")
    }
}
