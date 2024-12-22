//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Cohere
import XCTest

final class EmbeddingsTests: XCTestCase {
        
    func testTextEmbeddings() async {
        let textInput = ["Cat", "Dog"]
        do {
            let embeddings = try await client.createEmbeddings(
                for: .embedEnglishV2,
                texts: textInput,
                inputType: .classification,
                embeddingTypes: nil,
                truncate: nil
            )
            
            let embeddingsData = embeddings.embeddings
            XCTAssertTrue(!embeddingsData.isEmpty)
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
            model: Cohere.Model.embedEnglishV2.__conversion()
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
