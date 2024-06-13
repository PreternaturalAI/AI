//
// Copyright (c) Vatsal Manot
//

import Compute
import CoreMI
import Merge
import Swallow

/// A unified interface to a large language model.
public protocol LLMRequestHandling: CoreMI.RequestHandling {    
    /// Complete a given prompt.
    func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion
    
    /// Stream a completion for a given chat prompt.
    func completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream
}

extension MIContext {
    /// Complete a given prompt.
    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion {
        let llm = try await _firstHandler(ofType: (any LLMRequestHandling).self)
        
        return try await llm.complete(
            prompt: prompt,
            parameters: parameters
        )
    }
    
    /// Stream a completion for a given chat prompt.
    public func completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream {
        let llm = try await _firstHandler(ofType: (any LLMRequestHandling).self)

        return try await llm.completion(for: prompt)
    }
    
    /// Stream a completion for a given chat prompt.
    public func stream(
        _ prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream {
        try await completion(for: prompt)
    }
}

// MARK: - Implementation

extension LLMRequestHandling {
    public var _availableModels: [ModelIdentifier]? {
        return nil
    }
    
    public func completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream {
        AbstractLLM.ChatCompletionStream {
            try await self.complete(
                prompt: prompt,
                parameters: try prompt.context.completionParameters.map({ try cast($0) }) ?? nil
            )
        }
    }
}

// MARK: - Extensions

extension LLMRequestHandling {
    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt
    ) async throws -> Prompt.Completion where Prompt.CompletionParameters: ExpressibleByNilLiteral {
        try await complete(
            prompt: prompt,
            parameters: nil
        )
    }
    
    public func complete(
        prompt: AbstractLLM.ChatPrompt,
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        var prompt = prompt
        
        prompt.context = try withMutableScope(prompt.context) { context in
            context.completionType = .chat
            context.modelIdentifier = try .one(model.__conversion())
        }
        
        return try await complete(prompt: prompt)
    }

    public func complete(
        _ messages: [AbstractLLM.ChatMessage],
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        let prompt = AbstractLLM.ChatPrompt(
            messages: messages,
            context: try withMutableScope(PromptContextValues.current) { context in
                context.completionType = .chat
                context.modelIdentifier = try .one(model.__conversion())
            }
        )
        
        return try await complete(prompt: prompt)
    }
    
    public func complete(
        messages: [AbstractLLM.ChatMessage],
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        let prompt = AbstractLLM.ChatPrompt(
            messages: messages,
            context: try withMutableScope(PromptContextValues.current) { context in
                context.completionType = .chat
                context.modelIdentifier = try .one(model.__conversion())
            }
        )
        
        return try await complete(prompt: prompt)
    }
    
    public func complete(
        _ messages: [AbstractLLM.ChatMessage]
    ) async throws -> AbstractLLM.ChatCompletion {
        let prompt = AbstractLLM.ChatPrompt(
            messages: messages
        )
        
        return try await complete(prompt: prompt)
    }
    
    public func completion(
        for messages: [AbstractLLM.ChatMessage]
    ) async throws -> AbstractLLM.ChatCompletionStream {
        let prompt = AbstractLLM.ChatPrompt(
            messages: messages
        )
        
        return try await completion(for: prompt)
    }
    
    public func complete(
        _ message: AbstractLLM.ChatMessage,
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        try await complete([message], model: model)
    }

    public func complete(
        prompt: AbstractLLM.ChatOrTextPrompt,
        parameters: any AbstractLLM.CompletionParameters
    ) async throws -> AbstractLLM.ChatOrTextCompletion {
        switch prompt {
            case .text(let prompt):
                let completion = try await complete(
                    prompt: prompt,
                    parameters: cast(parameters)
                )
                
                return .text(completion)
            case .chat(let prompt):
                let completion = try await complete(
                    prompt: prompt,
                    parameters: cast(parameters)
                )
                
                return .chat(completion)
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "LLMRequestHandling")
public typealias LargeLanguageModelServices = LLMRequestHandling
