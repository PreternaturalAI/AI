//
// Copyright (c) Preternatural AI, Inc.
//

import Jina
import LargeLanguageModels
import XCTest

final class EmbeddingsTests: XCTestCase {
        
    func testTextEmbeddings() async {
        let textInput = ["Hello", "World"]
        do {
            let embeddings = try await client.createEmbeddings(
                for: .embeddingsV2BaseEn,
                input: textInput,
                encodingFormat: nil
            )
            
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
            model: Jina.Model.embeddingsV2SmallEn.__conversion()
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
