

import CorePersistence
import LargeLanguageModels
import NetworkKit
import Swallow

extension xAI.Client: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: TaskDependencies {
        var result = TaskDependencies()
        
        result[\.llm] = self
        
        return result
    }
}

extension xAI.Client: LLMRequestHandling {
    public var _availableModels: [ModelIdentifier]? {
        xAI.Model.allCases.map({ $0.__conversion() })
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
        
        var messages: [xAI.ChatMessage] = []
        for message in prompt.messages {
            let chatMessage = try await xAI.ChatMessage(from: message)
            messages.append(chatMessage)
        }
        
        let response: xAI.ChatCompletion = try await run(
            \.chatCompletions,
             with: .init(
                messages: messages,
                model: _model(for: prompt, parameters: parameters),
                maxTokens: parameters.tokenLimit?.fixedValue,
                seed: nil,
                stream: false,
                temperature: parameters.temperatureOrTopP?.temperature,
                topProbabilityMass: parameters.temperatureOrTopP?.topProbabilityMass,
                functions: parameters.functions?.map { xAI.ChatFunctionDefinition(from: $0) }
             )
        )
        
        assert(response.choices.count == 1)
        
        let message = try AbstractLLM.ChatMessage(from: response, choiceIndex: 0)
        
        return AbstractLLM.ChatCompletion(
            prompt: prompt.messages,
            message: message,
            stopReason: .init() // FIXME: !!!
        )
    }
    
    private func _model(
        for prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters?
    ) throws -> xAI.Model {
        try prompt.context.get(\.modelIdentifier)?.as(xAI.Model.self) ?? .grok_beta
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatRole {
    public init(
        from role: xAI.ChatRole
    ) throws {
        switch role {
            case .system:
                self = .system
            case .user:
                self = .user
            case .assistant:
                self = .assistant
            case .function:
                self = .other(.function)
        }
    }
}

extension AbstractLLM.ChatMessage {
    public init(
        from completion: xAI.ChatCompletion,
        choiceIndex: Int
    ) throws {
        let choice = completion.choices[choiceIndex]
        
        self.init(
            id: AnyPersistentIdentifier(erasing: "\(completion.id)_\(choiceIndex.description)"),
            role: try AbstractLLM.ChatRole(from: choice.message.role),
            content: PromptLiteral(choice.message.body.description)
        )
    }
}

extension xAI.ChatMessage {
    public init(
        from message: AbstractLLM.ChatMessage
    ) throws {
        self.init(
            role: xAI.ChatRole(
                from: message.role
            ),
            content: try message.content._stripToText()
        )
    }
}

extension xAI.ChatFunctionDefinition {
    public init(
        from function: AbstractLLM.ChatFunctionDefinition
    ) {
        self.init(
            name: function.name.rawValue,
            description: function.context,
            parameters: function.parameters
        )
    }
}
