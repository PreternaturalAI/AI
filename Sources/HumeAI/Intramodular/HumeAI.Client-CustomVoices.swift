//
// Copyright (c) Preternatural AI, Inc.
//

import Merge
import NetworkKit
import SwiftAPI

extension HumeAI.Client {
    public func listCustomVoices() async throws -> [HumeAI.Voice] {
        let response = try await run(\.listCustomVoices)
        
        return response.customVoicesPage
    }
    
    public func createCustomVoice(
        name: String,
        baseVoice: String,
        parameterModel: String,
        parameters: HumeAI.Voice.Parameters? = nil
    ) async throws -> HumeAI.Voice {
        let input = HumeAI.APISpecification.RequestBodies.CreateVoiceInput(
            name: name,
            baseVoice: baseVoice,
            parameterModel: parameterModel,
            parameters: parameters
        )
        
        return try await run(\.createCustomVoice, with: input)
    }
    
    public func getCustomVoice(
        id: String
    ) async throws -> HumeAI.Voice {
        let input = HumeAI.APISpecification.PathInput.ID(id: id)
        
        return try await run(\.getCustomVoice, with: input)
    }
    
    public func createCustomVoiceVersion(
        id: String,
        baseVoice: String,
        parameterModel: String,
        parameters: HumeAI.Voice.Parameters? = nil
    ) async throws -> HumeAI.Voice {
        let input = HumeAI.APISpecification.RequestBodies.CreateVoiceVersionInput(
            id: id,
            baseVoice: baseVoice,
            parameterModel: parameterModel,
            parameters: parameters
        )
        
        return try await run(\.createCustomVoiceVersion, with: input)
    }
    
    public func deleteCustomVoice(
        id: String
    ) async throws {
        let input = HumeAI.APISpecification.PathInput.ID(id: id)
        try await run(\.deleteCustomVoice, with: input)
    }
    
    public func updateCustomVoiceName(
        id: String,
        name: String
    ) async throws {
        let input = HumeAI.APISpecification.RequestBodies.UpdateVoiceNameInput(
            id: id,
            name: name
        )
        try await run(\.updateCustomVoiceName, with: input)
    }
}
