//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import Swallow

extension Anthropic.Client: LLMRequestHandling {
    public var _availableModels: [ModelIdentifier]? {
        Anthropic.Model.allCases.map({ $0.__conversion() })
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
        let response = try await run(
            \.complete,
             with: Anthropic.API.RequestBodies.Complete(
                prompt: prompt.prefix.promptLiteral._stripToText(),
                model: .claude_3_opus_20240229,
                maxTokensToSample: parameters.tokenLimit.fixedValue ?? 256,
                stopSequences: parameters.stops,
                stream: false,
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
    
    private func _completeUsingTextPrompt(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters
    ) async throws -> AbstractLLM.ChatCompletion {
        let completion: AbstractLLM.TextCompletion = try await _complete(
            prompt: AbstractLLM.TextPrompt(
                prefix: PromptLiteral(stringLiteral: prompt.messages.anthropicPromptString)
            ),
            parameters: .init(
                tokenLimit: parameters.tokenLimit ?? .max,
                stops: parameters.stops
            )
        )
        
        let isAssistantReply: Bool = (prompt.messages.last?.role ?? .user) == .user
        let content: String = completion.text
        let message = AbstractLLM.ChatMessage(
            id: UUID(),
            role: (isAssistantReply ? .assistant : .user),
            content: content
        )
        
        return AbstractLLM.ChatCompletion(
            prompt: prompt.messages,
            message: message,
            stopReason: AbstractLLM.ChatCompletion.StopReason() // FIXME: !!!
        )
    }
    
    private func _complete(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters
    ) async throws -> AbstractLLM.ChatCompletion {
        let response = try await run(
            \.createMessage,
             with: createMessageRequestBody(from: prompt, parameters: parameters, stream: false)
        )
        
        let message = try Anthropic.ChatMessage(
            role: response.role,
            content: response.content
        )
        
        return try AbstractLLM.ChatCompletion(
            prompt: prompt.messages,
            message: message.__conversion(),
            stopReason: response.stopReason?.__conversion()
        )
    }
    
    public func completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AbstractLLM.ChatCompletionStream {        
        return AbstractLLM.ChatCompletionStream.init {
            try await self._completion(for: prompt)
        }
    }
    
    private func _completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error> {
        let requestBody = try await createMessageRequestBody(from: prompt, stream: true)
        
        let request = try HTTPRequest(url: "https://api.anthropic.com/v1/messages")
            .jsonBody(requestBody, keyEncodingStrategy: .convertToSnakeCase)
            .method(.post)
            .header(.contentType(.json))
            .header("X-API-Key", interface.configuration.apiKey.unwrap().value)
            .header("anthropic-version", "2023-06-01")
        
        let sessionConfiguration = URLSessionConfiguration.default
        
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(INT_MAX)
        sessionConfiguration.httpAdditionalHeaders ??= [:]
        sessionConfiguration.httpAdditionalHeaders!["Accept"] = "text/event-stream"
        sessionConfiguration.httpAdditionalHeaders!["Cache-Control"] = "no-cache"
        
        let session = URLSession(configuration: sessionConfiguration)
        
        let events = ServerSentEvents.EventSource(request: try URLRequest(request), session: session)
        
        let result = AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error> { (continuation: AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>.Continuation) in
            let task = Task<Void, Swift.Error>(priority: .userInitiated) { () -> Void in
                for await sseEvent in events.values {
                    try Task.checkCancellation()
                    
                    do {
                        guard let eventMessage = try sseEvent.message else {
                            continue
                        }

                        let event: Anthropic.API.ResponseBodies.CreateMessageStreamEvent = try eventMessage.decode(Anthropic.API.ResponseBodies.CreateMessageStreamEvent.self)

                        guard event.type != .message_start && event.type != .message_stop else {
                            continue
                        }
                        
                        guard
                            let content: Anthropic.API.ResponseBodies.CreateMessageStreamEvent.Delta = event.delta,
                            let text: String = content.text
                        else {
                            continue
                        }
                        
                        let message = AbstractLLM.ChatMessage(
                            role: .assistant,
                            content: PromptLiteral(stringLiteral: text)
                        )
                        
                        continuation.yield(.completion(AbstractLLM.ChatCompletion.Partial(delta: message)))
                    } catch {
                        let streamError: Error
                        
                        if let apiError = try? sseEvent.message?.decode(Anthropic.API.ResponseBodies.ErrorWrapper.self).error {
                            streamError = apiError
                        } else {
                            streamError = error
                        }
                        
                        continuation.yield(with: .failure(streamError))
                        continuation.finish()
                        
                        runtimeIssue(streamError)
                    
                        return
                    }
                }
                
                continuation.yield(.stop)
                
                return continuation.finish()
            }
            
            continuation.onTermination = { _ in
                Task.detached {
                    await events.close()
                }
                
                task.cancel()
            }
            
            return
        }
               
        return result
    }
    
    private func createMessageRequestBody(
        from prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters? = nil,
        stream: Bool
    ) async throws -> Anthropic.API.RequestBodies.CreateMessage {
        var prompt: AbstractLLM.ChatPrompt = prompt
        let parameters: AbstractLLM.ChatCompletionParameters? = try parameters ?? cast(prompt.context.completionParameters)
        let model: Anthropic.Model = try await _model(for: prompt)
        
        /// Anthropic doesn't support a `system` role.
        let system: String? = try prompt.messages
            .removeFirst(byUnwrapping: { $0.role == .system ? $0.content : nil })
            .map({ try $0._stripToText() })
        
        let messages = try await prompt.messages.concurrentMap { (message: AbstractLLM.ChatMessage) in
            try await Anthropic.ChatMessage(from: message)
        }
        
        let requestBody = Anthropic.API.RequestBodies.CreateMessage(
            model: model,
            messages: messages,
            tools: try (parameters?.functions ?? []).map {
                try Anthropic.Tool(_from: $0)
            },
            system: system,
            maxTokens: parameters?.tokenLimit?.fixedValue ?? 4000, // FIXME: Hardcoded,
            temperature: parameters?.temperatureOrTopP?.temperature,
            topP: parameters?.temperatureOrTopP?.topProbabilityMass,
            topK: nil,
            stopSequences: parameters?.stops,
            stream: stream,
            metadata: nil
        )
        
        return requestBody
    }
    
    private func _model(
        for prompt: any AbstractLLM.Prompt
    ) async throws -> Anthropic.Model {
        do {
            guard let modelIdentifierScope: ModelIdentifierScope = prompt.context.get(\.modelIdentifier) else {
                return Anthropic.Model.claude_3_opus_20240229
            }
            
            let modelIdentifier: ModelIdentifier = try modelIdentifierScope._oneValue
            
            return try Anthropic.Model(from: modelIdentifier)
        } catch {
            runtimeIssue("Failed to resolve model identifier.")
            
            throw error
        }
    }
}

// MARK: - Auxiliary

extension Sequence where Element == AbstractLLM.ChatMessage {
    fileprivate var anthropicPromptString: String {
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
