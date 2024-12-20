//
//  _Gemini.Client+FineTuning.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Foundation

extension _Gemini.Client {
    public func createTunedModel(
        config: _Gemini.TuningConfig
    ) async throws -> _Gemini.TuningOperation {
        let input = _Gemini.APISpecification.RequestBodies.CreateTunedModel(
            requestBody: config
        )
        return try await run(\.createTunedModel, with: input)
    }
    
    public func getTuningOperation(
        operationName: String
    ) async throws -> _Gemini.TuningOperation {
        let input = _Gemini.APISpecification.RequestBodies.GetOperation(
            operationName: operationName
        )
        return try await run(\.getTuningOperation, with: input)
    }
    
    public func getTunedModel(
        modelName: String
    ) async throws -> _Gemini.TunedModel {
        let input = _Gemini.APISpecification.RequestBodies.GetTunedModel(
            modelName: modelName
        )
        return try await run(\.getTunedModel, with: input)
    }
    
    public func generateWithTunedModel(
        modelName: String,
        input: String,
        config: _Gemini.GenerationConfiguration = configDefault
    ) async throws -> _Gemini.Content {
        let messages = [
            _Gemini.Message(role: .user, content: input)
        ]
        
        let contents = messages.filter { $0.role != .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        }
        
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: .tunedModel(modelName),
            requestBody: .init(
                contents: contents,
                generationConfig: config
            )
        )
        
        let response = try await run(\.generateTunedContent, with: input)
        return try _Gemini.Content(apiResponse: response)
    }
    
    public func waitForTuningCompletion(
        operation: _Gemini.TuningOperation,
        pollingInterval: TimeInterval = 5.0,
        timeout: TimeInterval = 3600.0
    ) async throws -> _Gemini.TunedModel {
        let startTime = Date()
        var currentOperation = operation
        
        while true {
            if Date().timeIntervalSince(startTime) > timeout {
                throw _Gemini.APIError.unknown(message: "Tuning operation timed out")
            }
            
            if let tunedModelName = currentOperation.metadata?.tunedModel {
                // Get the model status
                let model = try await getTunedModel(modelName: tunedModelName)
                
                switch model.state {
                    case .active:
                        return model
                    case .failed:
                        throw _Gemini.APIError.unknown(message: "Model tuning failed")
                    case .creating:
                        // Continue polling
                        try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
                    case .stateUnspecified:
                        throw _Gemini.APIError.unknown(message: "Invalid model state")
                }
            }
            
            if let error = currentOperation.error {
                throw _Gemini.APIError.unknown(message: "Tuning failed: \(error.message)")
            }
            
            try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
            currentOperation = try await getTuningOperation(operationName: currentOperation.name)
        }
    }
}
