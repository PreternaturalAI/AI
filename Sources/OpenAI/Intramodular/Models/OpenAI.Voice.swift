//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI.Client {
    public func createSpeech(
        model: OpenAI.Model,
        text: String,
        voice: OpenAI.Speech.Voice = .alloy,
        speed: Double?
    ) async throws -> OpenAI.Speech {
        let requestBody = OpenAI.APISpecification.RequestBodies.CreateSpeech(
            model: model,
            input: text,
            voice: voice,
            speed: speed
        )
      
        let data = try await run(\.createSpeech, with: requestBody)
      
        return OpenAI.Speech(data: data)
    }
    
    public func createSpeech(
        model: OpenAI.Model.Speech,
        text: String,
        voice: OpenAI.Speech.Voice = .alloy,
        speed: Double?
    ) async throws -> OpenAI.Speech {
        let requestBody = OpenAI.APISpecification.RequestBodies.CreateSpeech(
            model: OpenAI.Model.speech(model),
            input: text,
            voice: voice,
            speed: speed
        )
        
        let data = try await run(\.createSpeech, with: requestBody)
        
        return OpenAI.Speech(data: data)
    }
}
