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
    
    func testGetVectorStore() async throws {
        let vectorStores = try await client.listVectorStores()
        let vectorStoreID = vectorStores.firstID!
        
        let result = try await client.getVectorStore(vectorStoreID: vectorStoreID)
        
        _ = result
    }
    
    func testUpdateVectorStore() async throws {
        let vectorStores = try await client.listVectorStores()
        let vectorStoreID = vectorStores.firstID!
        let newName = "myUpdatedVectorStore"
        
        let result = try await client.updateVectorStore(
            vectorStoreID: vectorStoreID,
            name: newName,
            expiresAfter: nil,
            metadata: ["key" : "value"])
        
        _ = result
    }
    
    func testDeleteVectorStore() async throws {
        let vectorStores = try await client.listVectorStores()
        let vectorStoreID = vectorStores.firstID!
        
        let result = try await client.deleteVectorStore(vectorStoreID: vectorStoreID)
        
        _ = result
    }
}
