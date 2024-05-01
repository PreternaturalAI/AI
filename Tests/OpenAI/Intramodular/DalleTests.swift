//
//  DalleTests.swift
//
//
//  Created by Natasha Murashev on 5/1/24.
//

import OpenAI
import XCTest

final class DalleTests: XCTestCase {

    func testCreateImage() async throws {
        let result = try await client.createImage(
            prompt: "a kitten playing with yarn")
        
        _ = result
    }
}

