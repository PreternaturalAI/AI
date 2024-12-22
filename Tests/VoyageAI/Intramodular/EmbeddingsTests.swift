//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import VoyageAI
import XCTest

final class EmbeddingsTests: XCTestCase {
        
    func testTextEmbeddings() async {
        let textInput = ["Cat", "Dog"]
        do {
            let embeddings = try await client.createEmbeddings(
                for: .voyageLarge2,
                input: textInput
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
        
        let textInput = ["Cat", "Dog"]
        let request = TextEmbeddingsRequest(
            input: textInput,
            model: VoyageAI.Model.voyage2.__conversion()
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
