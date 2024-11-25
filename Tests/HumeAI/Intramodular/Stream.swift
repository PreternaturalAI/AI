//
//  Stream.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientStreamTests: XCTestCase {
    
    func testStreamInference() async throws {
        let job = try await client.streamInference(
            id: "test-id",
            file: Data(),
            models: [.language]
        )
        XCTAssertNotNil(job)
    }
}
