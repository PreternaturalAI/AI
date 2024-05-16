//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/16/24.
//

import Foundation
import LargeLanguageModels
import NetworkKit

extension OpenAI.APIClient {
    
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
}
