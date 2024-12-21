//
// Copyright (c) Preternatural AI, Inc.
//

@testable import HumeAI
import XCTest

final class HumeAIClientStreamTests: XCTestCase {
    
    func testStreamInference() async throws {
        let job = try await client.streamInference(
            id: "test-id",
            file: Data(),
            models: [.language()]
        )
        XCTAssertNotNil(job)
    }
}
