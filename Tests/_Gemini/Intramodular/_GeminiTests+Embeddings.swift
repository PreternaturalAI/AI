//
// Copyright (c) Preternatural AI, Inc.
//

import AI
import Foundation
import Testing
import _Gemini

@Suite struct _GeminiEmbeddingTests {
    @Test func testGenerateEmbedding() async throws {
        let text = "What is the meaning of life?"
        
        let embedding = try await client.generateEmbedding(text: text)
        
        // Basic validation checks
        #expect(!embedding.isEmpty, "Embedding should not be empty")
        #expect(embedding.count > 0, "Embedding should have multiple dimensions")
        
        // Validate embedding values are within expected range
        for value in embedding {
            #expect(value >= -1.0 && value <= 1.0, "Embedding values should be normalized between -1 and 1")
        }
        
        // Print some basic statistics
        let sum = embedding.reduce(0, +)
        let average = sum / Double(embedding.count)
        print("Embedding statistics:")
        print("- Dimensions:", embedding.count)
        print("- Average value:", average)
        print("- First few values:", Array(embedding.prefix(5)))
    }
}
