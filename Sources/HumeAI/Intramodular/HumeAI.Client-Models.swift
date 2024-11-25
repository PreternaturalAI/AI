//
//  HumeAI.Client-Models.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

//FIXME: - Not correct Model structure

extension HumeAI.Client {
    public func listModels() async throws -> [HumeAI.Model] {
        let response = try await run(\.listModels)
        return response.models
    }
    
    public func getModel(
        id: String
    ) async throws -> HumeAI.Model {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        return try await run(\.getModel, with: input)
    }
    
    public func updateModelName(
        id: String,
        name: String
    ) async throws -> HumeAI.Model {
        let input = HumeAI.APISpecification.RequestBodies.UpdateModelNameInput(
            id: id,
            name: name
        )
        return try await run(\.updateModelName, with: input)
    }
}