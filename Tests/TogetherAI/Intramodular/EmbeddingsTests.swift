//
// Copyright (c) Preternatural AI, Inc.
//

import LargeLanguageModels
import VoyageAI
import XCTest

final class EmbeddingsTests: XCTestCase {
    
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
