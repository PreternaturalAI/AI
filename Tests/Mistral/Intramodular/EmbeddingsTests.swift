//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import XCTest
import Mistral

final class EmbeddingsTests: XCTestCase {
        
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
    
    func testTextEmbeddingsRequestHandling() async {
        let embeddingsClient: any TextEmbeddingsRequestHandling = client
        
        let textInput = ["Hello", "World"]
        let request = TextEmbeddingsRequest(
            input: textInput,
            model: Mistral.Model.mistral_embed.__conversion()
        )
        
        do {
            let embeddings = try await embeddingsClient.fulfill(request)
            let embeddingsData = embeddings.data
            XCTAssertTrue(!embeddingsData.isEmpty)
        } catch {
            print(error)
            XCTFail(error.localizedDescription)
        }
    }
    
}
