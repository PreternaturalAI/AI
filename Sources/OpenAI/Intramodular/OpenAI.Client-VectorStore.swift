//
// Copyright (c) Vatsal Manot
//

import Foundation
import LargeLanguageModels
import NetworkKit

extension OpenAI.Client {
    public func createVectorStore(
        name: String?,
        fileIDs: [String]?,
        expiresAfter: OpenAI.VectorStore.ExpiresAfter? = nil,
        metadata: [String: String]? = nil
    ) async throws -> OpenAI.VectorStore {

        let requestBody = OpenAI.APISpecification.RequestBodies.CreateVectorStore(
            name: name,
            fileIDs: fileIDs,
            expiresAfter: expiresAfter,
            metadata: metadata
        )
        
        let response = try await run(\.createVectorStore, with: requestBody)
        
        return response
    }
    
    public func listVectorStores(
        limit: Int? = nil,
        order: OpenAI.VectorStore.Order? = nil,
        after: String? = nil,
        before: String? = nil
    ) async throws -> OpenAI.List<OpenAI.VectorStore> {

        let requestBody = OpenAI.APISpecification.RequestBodies.ListVectorStores(
            limit: limit,
            order: order,
            after: after,
            before: before
        )
        
        let response = try await run(\.listVectorStores, with: requestBody)
        
        return response
    }
    
    public func getVectorStore(
        vectorStoreID: String
    ) async throws -> OpenAI.VectorStore {

        let requestBody = OpenAI.APISpecification.RequestBodies.GetVectorStore(vector_store_id: vectorStoreID)
        
        let response = try await run(\.getVectorStore, with: requestBody)
        
        return response
    }
    
    public func updateVectorStore(
        vectorStoreID: String,
        name: String?,
        expiresAfter: OpenAI.VectorStore.ExpiresAfter?,
        metadata: [String: String]?
    ) async throws -> OpenAI.VectorStore {

        let requestBody = OpenAI.APISpecification.RequestBodies.UpdateVectorStore(
            vectorStoreID: vectorStoreID,
            name: name,
            expiresAfter: expiresAfter,
            metadata: metadata)
        
        let response = try await run(\.updateVectorStore, with: requestBody)
        
        return response
    }
    
    public func deleteVectorStore(
        vectorStoreID: String
    ) async throws -> OpenAI.VectorStore {

        let requestBody = OpenAI.APISpecification.RequestBodies.DeleteVectorStore(vector_store_id: vectorStoreID)
        
        let response = try await run(\.deleteVectorStore, with: requestBody)
        
        return response
    }
}
