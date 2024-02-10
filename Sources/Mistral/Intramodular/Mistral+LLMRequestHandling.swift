//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import Swallow

extension Mistral: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: Dependencies {
        var result = Dependencies()
        
        result[\.llmServices] = self
        
        return result
    }
}

extension Mistral: LLMRequestHandling {
    public var _availableLLMs: [_GMLModelIdentifier]? {
        Mistral.Model.allCases.map({ $0.__conversion() })
    }

    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> Prompt.Completion {
        let _completion: Any
        
        switch prompt {
            case let prompt as AbstractLLM.TextPrompt:
                _completion = try await _complete(
                    prompt: prompt,
                    parameters: try cast(parameters),
                    heuristics: heuristics
                )
                
            case let prompt as AbstractLLM.ChatPrompt:
                _completion = try await _complete(
                    prompt: prompt,
                    parameters: try cast(parameters),
                    heuristics: heuristics
                )
            default:
                throw LLMRequestHandlingError.unsupportedPromptType(Prompt.self)
        }
        
        return try cast(_completion)
    }
    
    private func _complete(
        prompt: AbstractLLM.TextPrompt,
        parameters: AbstractLLM.TextCompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> AbstractLLM.TextCompletion {
        throw LLMRequestHandlingError.unsupportedPromptType(.init(Swift.type(of: prompt)))
    }
    
    private func _complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> AbstractLLM.ChatCompletion {
        let response: Mistral.APISpecification.ResponseBodies.ChatCompletion = try await run(
            \.chatCompletions,
             with: .init(
                model: _model(for: prompt, parameters: parameters, heuristics: heuristics),
                messages: try prompt.messages.map {
                    try Mistral.ChatMessage(from: $0)
                },
                temperature: parameters.temperatureOrTopP?.temperature,
                topP: parameters.temperatureOrTopP?.topProbabilityMass,
                maxTokens: parameters.tokenLimit?.fixedValue,
                stream: false,
                safeMode: false,
                randomSeed: nil
             )
        )
        
        assert(response.choices.count == 1)
        
        let message = try AbstractLLM.ChatMessage(from: response, choiceIndex: 0)
        
        return AbstractLLM.ChatCompletion(
            message: message,
            stopReason: .init() // FIXME!!!
        )
    }
    
    private func _model(
        for prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters?,
        heuristics: AbstractLLM.CompletionHeuristics?
    ) throws -> Mistral.Model {
        try prompt.context.get(\.modelIdentifier)?.as(Mistral.Model.self) ?? .mistral_medium
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatRole {
    public init(
        from role: Mistral.ChatMessage.Role
    ) throws {
        switch role {
            case .system:
                self = .system
            case .user:
                self = .user
            case .assistant:
                self = .assistant
        }
    }
}

extension AbstractLLM.ChatMessage {
    public init(
        from completion: Mistral.APISpecification.ResponseBodies.ChatCompletion,
        choiceIndex: Int
    ) throws {
        let choice = completion.choices[choiceIndex]
        
        self.init(
            id: AnyPersistentIdentifier(erasing: "\(completion.id)_\(choiceIndex.description)"),
            role: try AbstractLLM.ChatRole(from: choice.message.role),
            content: PromptLiteral(choice.message.content)
        )
    }
}

extension Mistral.ChatMessage {
    public init(
        from message: AbstractLLM.ChatMessage
    ) throws {
        self.init(
            role: try Mistral.ChatMessage.Role(
                from: message.role
            ),
            content: try message.content._stripToText()
        )
    }
}

extension Mistral.ChatMessage.Role {
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
