//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import OpenAI
import Swallow

extension XAI.Client: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: TaskDependencies {
        var result = TaskDependencies()
        
        result[\.llm] = self
        
        return result
    }
}

extension XAI.Client: LLMRequestHandling {
    public var _availableModels: [ModelIdentifier]? {
        XAI.Model.allCases.map({ $0.__conversion() })
    }
    
    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion {
        let _completion: Any
        
        switch prompt {
            case let prompt as AbstractLLM.TextPrompt:
                _completion = try await _complete(
                    prompt: prompt,
                    parameters: try cast(parameters)
                )
                
            case let prompt as AbstractLLM.ChatPrompt:
                _completion = try await _complete(
                    prompt: prompt,
                    parameters: try cast(parameters)
                )
            default:
                throw LLMRequestHandlingError.unsupportedPromptType(Prompt.self)
        }
        
        return try cast(_completion)
    }
    
    private func _complete(
        prompt: AbstractLLM.TextPrompt,
        parameters: AbstractLLM.TextCompletionParameters
    ) async throws -> AbstractLLM.TextCompletion {
        throw LLMRequestHandlingError.unsupportedPromptType(.init(Swift.type(of: prompt)))
    }
    
    private func _complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters
    ) async throws -> AbstractLLM.ChatCompletion {
        let response: XAI.APISpecification.ResponseBodies.ChatCompletion = try await run(
            \.chatCompletions,
             with: .init(
                messages: try await prompt.messages.asyncMap {
                    try await XAI.ChatMessage(from: $0)
                },
                model: _model(for: prompt, parameters: parameters),
                maxTokens: parameters.tokenLimit?.fixedValue,
                temperature: parameters.temperatureOrTopP?.temperature
             )
        )
        
        assert(response.choices.count == 1)
        
        let message = try AbstractLLM.ChatMessage(from: response.choices[0])
        
        return AbstractLLM.ChatCompletion(
            prompt: prompt.messages,
            message: message,
            stopReason: .init() // FIXME: !!!
        )
    }
    
    private func _model(
        for prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters?
    ) throws -> XAI.Model {
        try prompt.context.get(\.modelIdentifier)?.as(XAI.Model.self) ?? XAI.Model.grokBeta
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatMessage {
    public init(
        from completion: XAI.APISpecification.ResponseBodies.ChatCompletion.Choice
    ) throws {
        try self.init(from: completion.message)
    }
}

extension XAI.ChatMessage.Role {
    public init(
        from role: AbstractLLM.ChatRole
    ) throws {
        switch role {
            case .system:
                self = .system
            case .user:
                self = .user
            case .assistant:
                self = .assistant
            case .other:
                throw Never.Reason.unsupported
        }
    }
}

