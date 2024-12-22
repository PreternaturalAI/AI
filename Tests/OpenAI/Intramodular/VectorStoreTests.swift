//
//  File.swift
//
//
//  Created by Natasha Murashev on 5/16/24.
//

import OpenAI
import XCTest

final class VectorStoreTests: XCTestCase {
    func test1CreateVectorStore() async throws {
        let result = try await client.createVectorStore(name: nil, fileIDs: nil)
        
        _ = result
    }
    
    func test2ListVectorStore() async throws {
        let result = try await client.listVectorStores()
        
        _ = result
    }
    
    func test3GetVectorStore() async throws {
        let vectorStores = try await client.listVectorStores()
        let vectorStoreID = try vectorStores.firstID.unwrap()
        
        let result = try await client.getVectorStore(vectorStoreID: vectorStoreID)
        
        _ = result
    }
    
    func test4UpdateVectorStore() async throws {
        let vectorStores = try await client.listVectorStores()
        let vectorStoreID = try vectorStores.firstID.unwrap()
        let newName = "myUpdatedVectorStore"
        
        let result = try await client.updateVectorStore(
            vectorStoreID: vectorStoreID,
            name: newName,
            expiresAfter: nil,
            metadata: ["key" : "value"])
        
        _ = result
    }
    
    func test5DeleteVectorStore() async throws {
        let vectorStores = try await client.listVectorStores()
        let vectorStoreID = vectorStores.firstID!
        
        let result = try await client.deleteVectorStore(vectorStoreID: vectorStoreID)
        
        _ = result
    }
}
