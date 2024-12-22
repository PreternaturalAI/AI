//
// Copyright (c) Vatsal Manot
//

import OpenAI
import XCTest

final class DalleTests: XCTestCase {
    func testGeneratingOneImage() async throws {
        let result = try await client.createImage(
            prompt: "a kitten playing with yarn"
        )
        
        _ = result
    }
}

