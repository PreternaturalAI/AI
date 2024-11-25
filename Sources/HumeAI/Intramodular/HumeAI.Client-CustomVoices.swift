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
    public func listCustomVoices() async throws -> [HumeAI.APISpecification.ResponseBodies.Voice] {
        let response = try await run(\.listCustomVoices)
        return response.voices
    }
    
    public func createCustomVoice(
        name: String,
        baseVoice: String,
        parameters: HumeAI.APISpecification.ResponseBodies.VoiceParameters
    ) async throws -> HumeAI.APISpecification.ResponseBodies.Voice {
        let input = HumeAI.APISpecification.RequestBodies.CreateVoiceInput(
            name: name,
            baseVoice: baseVoice,
            parameters: parameters
        )
        return try await run(\.createCustomVoice, with: input)
    }
    
    public func deleteCustomVoice(id: String) async throws {
        try await run(\.deleteCustomVoice, with: id)
    }
}
