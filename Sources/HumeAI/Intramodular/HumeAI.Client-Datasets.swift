//
//  HumeAI.Client-Datasets.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listDatasets() async throws -> [HumeAI.Dataset] {
        let response = try await run(\.listDatasets)
        return response.datasets
    }
    
    public func createDataset(
        name: String,
        description: String?,
        fileIds: [String]
    ) async throws -> HumeAI.Dataset {
        let input = HumeAI.APISpecification.RequestBodies.CreateDatasetInput(
            name: name,
            description: description,
            fileIds: fileIds
        )
        return try await run(\.createDataset, with: input)
    }
    
    public func deleteDataset(id: String) async throws {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        try await run(\.deleteDataset, with: input)
    }
}
