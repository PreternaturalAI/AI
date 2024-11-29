//
//  HumeAI.Client-Models.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listModels() async throws -> [HumeAI.Model] {
        let response = try await run(\.listModels)
        return response.models
    }
    
    public func getModel(
        id: String
    ) async throws -> HumeAI.Model {
        let input = HumeAI.APISpecification.PathInput.ID(id: id)
        return try await run(\.getModel, with: input)
    }
    
    public func updateModelName(
        id: String,
        name: String
    ) async throws {
        let input = HumeAI.APISpecification.RequestBodies.UpdateModelNameInput(
            id: id,
            name: name
        )
        try await run(\.updateModelName, with: input)
    }
    
    public func listModelVersions(
        id: String
    ) async throws -> [HumeAI.Model.ModelVersion] {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        return try await run(\.listModelVersions, with: input)
    }
    
    public func getModelVersion(
        id: String,
        version: Int
    ) async throws -> HumeAI.Model.ModelVersion {
        let input = HumeAI.APISpecification.PathInput.IDWithVersion(
            id: id,
            version: version
        )
        return try await run(\.getModelVersion, with: input)
    }
    
    public func updateModelDescription(
        id: String,
        versionId: String,
        description: String
    ) async throws {
        let input = HumeAI.APISpecification.RequestBodies.UpdateModelDescriptionInput(
            id: id,
            versionId: versionId,
            description: description
        )
        try await run(\.updateModelDescription, with: input)
    }
}
