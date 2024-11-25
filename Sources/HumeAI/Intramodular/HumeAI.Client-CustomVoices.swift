//
//  HumeAI.Client-CustomVoices.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listCustomVoices() async throws -> [HumeAI.Voice] {
        let response = try await run(\.listCustomVoices)
        return response.voices
    }
    
    public func createCustomVoice(
        name: String,
        baseVoice: String,
        model: HumeAI.Model,
        parameters: HumeAI.Voice.Parameters
    ) async throws -> HumeAI.Voice {
        let input = HumeAI.APISpecification.RequestBodies.CreateVoiceInput(
            name: name,
            baseVoice: baseVoice,
            parameterModel: HumeAI.paramaterModel,
            parameters: parameters
        )
        return try await run(\.createCustomVoice, with: input)
    }
    
    public func deleteCustomVoice(id: String) async throws {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        try await run(\.deleteCustomVoice, with: input)
    }
}
