//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import TogetherAI
import XCTest

final class EmbeddingsTests: XCTestCase {
    
    func testTextEmbeddingsRequesntHandling() async {
        let textEmbeddingsClient: any TextEmbeddingsRequestHandling = client
        let textInput = "Our solar system orbits the Milky Way galaxy at about 515,000 mph"
        
        do {
            let embeddings = try await textEmbeddingsClient.fulfill(
                .init(
                    input: [textInput],
                    model: ModelIdentifier(
                        from: TogetherAI.Model.Embedding.togetherM2Bert80M8KRetrieval
                    )
                )
            )
            let embeddingsData = embeddings.data
            XCTAssertTrue(!embeddingsData.isEmpty)
        } catch {
            XCTFail(String(describing: error))
        }
    }
    
    func testTextEmbeddings() async {
        let textInput = "Our solar system orbits the Milky Way galaxy at about 515,000 mph"
        do {
            let embeddings = try await client.createEmbeddings(
                for: .togetherM2Bert80M2KRetrieval,
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
}
