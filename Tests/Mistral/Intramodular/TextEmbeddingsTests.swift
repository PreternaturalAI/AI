//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Groq
import XCTest

final class CompletionTests: XCTestCase {
    
    let llm: any LLMRequestHandling = client
    
    func testTextEmbeddings() async {
        let textInput = ["Hello", "World"]
        do {
            let embeddings = try await client.createEmbeddings(for: textInput)
            let embeddingsData = embeddings.data
            XCTAssertTrue(!embeddingsData.isEmpty)
            XCTAssertTrue(embeddingsData.first!.object == "embedding")
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }
    
}
