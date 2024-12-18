//
//  _GeminiTests+Grounding.swift
//  AI
//
//  Created by Jared Davidson on 12/13/24.
//

import Testing
import Foundation
import _Gemini
import AI

@Suite struct _GeminiGroundingTests {
    @Test func testGroundingWithGoogleSearch() async throws {
        let messages = [
            _Gemini.Message(
                role: .user,
                content: "What are the latest developments in quantum computing?"
            )
        ]
        
        let response = try await client.generateContentWithGrounding(
            messages: messages,
            model: .gemini_1_5_pro_latest
        )
        
        print("Response:", response)
        
        // Basic response validation
        #expect(!response.text.isEmpty, "Response should not be empty")
        
        // Check if grounding metadata exists
        #expect(response.groundingMetadata != nil, "Grounding metadata should be present")
        
        if let metadata = response.groundingMetadata {
            // Validate search entry point
            #expect(metadata.searchEntryPoint?.renderedContent != nil, "Search entry point should be present")
            
            // Validate grounding chunks
            #expect(!metadata.groundingChunks.isEmpty, "Grounding chunks should not be empty")
            
            // Validate grounding supports
            #expect(!metadata.groundingSupports.isEmpty, "Grounding supports should not be empty")
            
            // Validate web search queries
            #expect(!metadata.webSearchQueries.isEmpty, "Web search queries should not be empty")
        }
        
        // Check token usage is present and valid
        if let usage = response.tokenUsage {
            #expect(usage.prompt > 0, "Prompt tokens should be greater than 0")
            #expect(usage.response > 0, "Response tokens should be greater than 0")
            #expect(usage.total > 0, "Total tokens should be greater than 0")
            #expect(usage.total == usage.prompt + usage.response, "Total tokens should equal prompt + response")
        }
        
        // Check finish reason
        #expect(response.finishReason == .stop, "Response should have completed normally")
    }
}
