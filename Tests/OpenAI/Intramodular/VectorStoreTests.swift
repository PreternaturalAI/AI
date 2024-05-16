//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/16/24.
//

import OpenAI
import XCTest

final class VectorStoreTests: XCTestCase {

    func testCreateVectorStore() async throws {
        let result = try await client.createVectorStore(name: nil, fileIDs: nil)

        _ = result
    }
    
    func testListVectorStore() async throws {
        let result = try await client.listVectorStores()

        _ = result
    }
}
