//
//  HumeAI.Client-Configs.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listConfigs() async throws -> [HumeAI.APISpecification.ResponseBodies.Config] {
        let response = try await run(\.listConfigs)
        return response.configs
    }
    
    public func createConfig(
        name: String,
        description: String?,
        settings: [String: String]
    ) async throws -> HumeAI.APISpecification.ResponseBodies.Config {
        let input = HumeAI.APISpecification.RequestBodies.CreateConfigInput(
            name: name,
            description: description,
            settings: settings
        )
        return try await run(\.createConfig, with: input)
    }
    
    public func deleteConfig(id: String) async throws {
        try await run(\.deleteConfig, with: id)
    }
}
