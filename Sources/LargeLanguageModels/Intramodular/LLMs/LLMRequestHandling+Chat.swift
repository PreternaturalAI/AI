//
// Copyright (c) Vatsal Manot
//

import CoreMI
import Swallow
import SwiftUIX

extension LLMRequestHandling {
    public func complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters,
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        var prompt = prompt
        
        prompt.context = try withMutableScope(prompt.context) { context in
            context.completionType = .chat
            context.modelIdentifier = try .one(model.__conversion())
        }
        
        let completion = try await complete(
            prompt: prompt,
            parameters: parameters
        )
        
        return completion
    }
    
    public func complete(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        var prompt = AbstractLLM.ChatPrompt(messages: messages)
        
        prompt.context = try withMutableScope(prompt.context) { context in
            context.completionType = .chat
            context.modelIdentifier = try .one(model.__conversion())
        }
        
        let completion = try await complete(
            prompt: prompt,
            parameters: parameters
        )
        
        return completion
    }
    
    public func complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters,
        functions: [AbstractLLM.ChatFunctionDefinition]
    ) async throws -> AbstractLLM.ChatCompletion {
        var parameters = parameters
        
        if parameters.functions == nil {
            parameters.functions = []
        }
        
        parameters.functions?.append(contentsOf: functions)
        
        let completion = try await complete(
            prompt: prompt,
            parameters: parameters
        )
        
        return completion
    }
    
    public func complete(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        functions: [AbstractLLM.ChatFunctionDefinition]
    ) async throws -> AbstractLLM.ChatCompletion {
        try await complete(
            prompt: AbstractLLM.ChatPrompt(messages: messages),
            parameters: parameters,
            functions: functions
        )
    }
    
    public func complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters,
        functions: [AbstractLLM.ChatFunctionDefinition],
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        var prompt = prompt
        
        prompt.context = try withMutableScope(prompt.context) { context in
            context.completionType = .chat
            context.modelIdentifier = try .one(model.__conversion())
        }
        
        return try await complete(
            prompt: prompt,
            parameters: parameters,
            functions: functions,
            model: model
        )
    }
    
    public func complete(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        functions: [AbstractLLM.ChatFunctionDefinition],
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletion {
        try await complete(
            prompt: AbstractLLM.ChatPrompt(messages: messages),
            parameters: parameters,
            functions: functions,
            model: model
        )
    }
    
    public func complete(
        prompt: AbstractLLM.ChatPrompt,
        functions: [AbstractLLM.ChatFunctionDefinition]
    ) async throws -> AbstractLLM.ChatCompletion {
        try await complete(
            prompt: prompt,
            parameters: nil,
            functions: functions
        )
    }
    
    public func complete(
        _ messages: [AbstractLLM.ChatMessage],
        functions: [AbstractLLM.ChatFunctionDefinition]
    ) async throws -> AbstractLLM.ChatCompletion {
        try await complete(
            prompt: AbstractLLM.ChatPrompt(messages: messages),
            parameters: nil,
            functions: functions
        )
    }
}

extension LLMRequestHandling {
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        functions: [AbstractLLM.ChatFunctionDefinition],
        model: some ModelIdentifierConvertible,
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: parameters,
            functions: functions,
            model: model
        )
        ._decode(as: Result.self)
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        functions: [AbstractLLM.ChatFunctionDefinition],
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: parameters,
            functions: functions
        )
        ._decode(as: Result.self)
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        functions: [AbstractLLM.ChatFunctionDefinition],
        model: some ModelIdentifierConvertible,
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: nil,
            functions: functions,
            model: model,
            as: resultType
        )
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        functions: [AbstractLLM.ChatFunctionDefinition],
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: nil,
            functions: functions,
            as: resultType
        )
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        functions: [AbstractLLM.ChatFunctionDefinition],
        as resultType: ChatCompletionDecodableResultType<Result>
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: nil,
            functions: functions,
            as: Result.self
        )
    }

    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        model: some ModelIdentifierConvertible,
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: parameters,
            model: model
        )
        ._decode(as: Result.self)
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        model: some ModelIdentifierConvertible,
        as resultType: ChatCompletionDecodableResultType<Result>
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: parameters,
            model: model,
            as: Result.self
        )
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters,
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages,
            parameters: parameters
        )
        ._decode(as: Result.self)
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        model: some ModelIdentifierConvertible,
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages,
            model: model
        )
        ._decode(as: resultType)
    }

    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        model: some ModelIdentifierConvertible,
        as resultType: ChatCompletionDecodableResultType<Result>
    ) async throws -> Result {
        try await complete(
            messages,
            model: model
        )
        ._decode(as: Result.self)
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        as resultType: Result.Type
    ) async throws -> Result {
        try await complete(
            messages
        )
        ._decode(as: Result.self)
    }
    
    public func complete<Result: AbstractLLM.ChatCompletionDecodable>(
        _ messages: [AbstractLLM.ChatMessage],
        as resultType: ChatCompletionDecodableResultType<Result>
    ) async throws -> Result {
        try await complete(
            messages
        )
        ._decode(as: Result.self)
    }
    
    public func complete(
        _ messages: [AbstractLLM.ChatMessage],
        parameters: AbstractLLM.ChatCompletionParameters
    ) async throws -> AbstractLLM.ChatCompletion {
        try await complete(
            prompt: AbstractLLM.ChatPrompt(messages: messages),
            parameters: parameters
        )
    }
}

extension LLMRequestHandling {
    /// Stream a completion for a given chat prompt.
    public func completion(
        for prompt: AbstractLLM.ChatPrompt,
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletionStream {
        var prompt = prompt
        
        prompt.context = try withMutableScope(prompt.context) { context in
            context.completionType = .chat
            context.modelIdentifier = try .one(model.__conversion())
        }
        
        return try await completion(for: prompt)
    }
    
    /// Stream a completion for a given chat prompt.
    public func completion(
        for messages: [AbstractLLM.ChatMessage],
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletionStream {
        let prompt = AbstractLLM.ChatPrompt(
            messages: messages,
            context: try withMutableScope(PromptContextValues.current) { context in
                context.completionType = .chat
                context.modelIdentifier = try .one(model.__conversion())
            }
        )
        
        return try await completion(for: prompt)
    }
}

extension LLMRequestHandling {
    /// Stream a completion for a given chat prompt.
    public func stream(
        _ prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream {
        try await completion(for: prompt)
    }
    
    /// Stream a completion for a given chat prompt.
    public func stream(
        _ prompt: AbstractLLM.ChatPrompt,
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletionStream {
        try await completion(for: prompt, model: model)
    }
    
    /// Stream a completion for a given chat prompt and a desired model.
    public func stream(
        _ messages: [AbstractLLM.ChatMessage],
        model: some ModelIdentifierConvertible
    ) async throws -> AbstractLLM.ChatCompletionStream {
        try await completion(for: messages, model: model)
    }
}
