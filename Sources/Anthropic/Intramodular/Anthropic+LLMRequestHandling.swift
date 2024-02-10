//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import NetworkKit
import Swallow

extension Anthropic: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: Dependencies {
        var result = Dependencies()
        
        result[\.llmServices] = self
        
        return result
    }
}

extension Anthropic: LLMRequestHandling {
    public var _availableModels: [_GMLModelIdentifier]? {
        Anthropic.Model.allCases.map({ $0.__conversion() })
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
        let response = try await run(
            \.complete,
             with: .init(
                prompt: prompt.prefix.promptLiteral._stripToText(),
                model: .claude_v2,
                maxTokensToSample: parameters.tokenLimit.fixedValue ?? 256,
                stopSequences: parameters.stops,
                temperature: parameters.temperatureOrTopP?.temperature,
                topK: nil,
                topP: parameters.temperatureOrTopP?.topProbabilityMass
             )
        )
        
        return AbstractLLM.TextCompletion(
            prefix: .init(_lazy: prompt.prefix),
            text: response.completion
        )
    }
    
    private func _complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> AbstractLLM.ChatCompletion {
        let completion = try await _complete(
            prompt: AbstractLLM.TextPrompt(
                prefix: PromptLiteral(stringLiteral: prompt.messages.promptString)
            ),
            parameters: .init(
                tokenLimit: parameters.tokenLimit ?? .max,
                stops: parameters.stops
            ),
            heuristics: heuristics
        )
        
        let isAssistantReply = (prompt.messages.last?.role ?? .user) == .user
        let content: String = completion.text
        let message = AbstractLLM.ChatMessage(
            id: UUID(),
            role: isAssistantReply ? .assistant : .user,
            content: content
        )
        
        return AbstractLLM.ChatCompletion(
            message: message,
            stopReason: .init() // FIXME!!!
        )
    }
}

// MARK: - Auxiliary

extension Sequence where Element == AbstractLLM.ChatMessage {
    fileprivate var promptString: String {
        get throws {
            var lines = try self.map {
                try "\($0.role.roleString): \($0.content)"
            }
            
            if lines.last?.hasSuffix("Assistant :") == true {
                assertionFailure()
            }
            
            lines.append("Assistant: ")
            
            return lines.joined(separator: "\n\n")
        }
    }
}

extension AbstractLLM.ChatRole {
    fileprivate var roleString: String {
        get throws {
            switch self {
                case .user:
                    return "Human"
                case .system:
                    return "Human"
                case .assistant:
                    return "Assistant"
                case .other:
                    throw Never.Reason.unsupported
            }
        }
    }
}
