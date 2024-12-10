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
        let model: XAI.Model = try self._model(for: prompt, parameters: parameters)
        let parameters = try cast(parameters, to: AbstractLLM.ChatCompletionParameters.self)
        let maxTokens: Int?
        
        do {
            switch (parameters.tokenLimit) {
                case .fixed(let count):
                    maxTokens = count
                case .max, .none:
                    maxTokens = nil
            }
        }
        
        let completion: OpenAI.ChatCompletion = try await self.createChatCompletion(
            messages: prompt.messages.asyncMap({ try await OpenAI.ChatMessage(from: $0) }),
            model: model,
            parameters: .init(
                from: parameters,
                model: model,
                messages: prompt.messages,
                maxTokens: maxTokens
            )
        )
        
        let message = try completion.choices.toCollectionOfOne().first.message
        
        return AbstractLLM.ChatCompletion(
            prompt: prompt.messages,
            message: try .init(from: message)
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

extension XAI.Client {
    public func createChatCompletion(
        messages: [XAI.ChatMessage],
        model: XAI.Model,
        parameters: XAI.Client.ChatCompletionParameters
    ) async throws -> OpenAI.ChatCompletion {
        let requestBody = XAI.APISpecification.RequestBodies.CreateChatCompletion(
            messages: messages,
            model: model,
            parameters: parameters,
            stream: false
        )
        
        return try await run(\.createChatCompletions, with: requestBody)
    }
}

extension XAI.Client.ChatCompletionParameters {
    public init(
        from parameters: AbstractLLM.ChatCompletionParameters,
        model: XAI.Model,
        messages _: [AbstractLLM.ChatMessage],
        maxTokens: Int? = nil
    ) throws {
        self.init(
            temperature: parameters.temperatureOrTopP?.temperature,
            topProbabilityMass: parameters.temperatureOrTopP?.topProbabilityMass,
            stop: parameters.stops,
            maxTokens: maxTokens,
            functions: parameters.functions?.map {
                OpenAI.ChatFunctionDefinition(from: $0)
            }
        )
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

extension XAI.APISpecification.RequestBodies.CreateChatCompletion {
    public init(
        messages: [XAI.ChatMessage],
        model: XAI.Model,
        parameters: XAI.Client.ChatCompletionParameters,
        user: String? = nil,
        stream: Bool
    ) {
        self.init(
            user: user,
            messages: messages,
            functions: parameters.functions,
            functionCallingStrategy: parameters.functionCallingStrategy,
            model: model,
            temperature: parameters.temperature,
            topProbabilityMass: parameters.topProbabilityMass,
            choices: parameters.choices,
            stream: stream,
            stop: parameters.stop,
            maxTokens: parameters.maxTokens,
            presencePenalty: parameters.presencePenalty,
            frequencyPenalty: parameters.frequencyPenalty,
            responseFormat: parameters.responseFormat
        )
    }
}

/*
 extension OpenAI.Client: LLMRequestHandling {
 private var _debugPrintCompletions: Bool {
 false
 }
 
 public var _availableModels: [ModelIdentifier]? {
 if let __cached_models {
 do {
 return try __cached_models.map({ try $0.__conversion() })
 } catch {
 runtimeIssue(error)
 }
 }
 
 return OpenAI.Model.allCases.map({ $0.__conversion() })
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
 let parameters = try cast(parameters, to: AbstractLLM.TextCompletionParameters.self)
 
 let model = OpenAI.Model.instructGPT(.davinci)
 
 let promptText = try prompt.prefix.promptLiteral
 let completion = try await self.createCompletion(
 model: model,
 prompt: promptText._stripToText(),
 parameters: .init(
 from: parameters,
 model: model,
 prompt: prompt.prefix
 )
 )
 
 let text = try completion.choices.toCollectionOfOne().first.text
 
 _debugPrint(
 prompt: prompt.debugDescription
 .delimited(by: .quotationMark)
 .delimited(by: "\n")
 ,
 completion: text
 .delimited(by: .quotationMark)
 .delimited(by: "\n")
 )
 
 
 return .init(prefix: promptText, text: text)
 }
 
 private func _complete(
 prompt: AbstractLLM.ChatPrompt,
 parameters: AbstractLLM.ChatCompletionParameters
 ) async throws -> AbstractLLM.ChatCompletion {
 let model = try self._model(for: prompt, parameters: parameters)
 let parameters = try cast(parameters, to: AbstractLLM.ChatCompletionParameters.self)
 let maxTokens: Int?
 
 do {
 switch (parameters.tokenLimit) {
 case .fixed(let count):
 maxTokens = count
 case .max, .none:
 /*let tokenizer = try await tokenizer(for: model)
  let tokens = try tokenizer.encode(prompt._rawContent)
  let contextSize = try model.contextSize
  
  maxTokens = contextSize - tokens.count*/
 maxTokens = nil
 }
 }
 
 let completion = try await self.createChatCompletion(
 messages: prompt.messages.asyncMap({ try await OpenAI.ChatMessage(from: $0) }),
 model: model,
 parameters: .init(
 from: parameters,
 model: model,
 messages: prompt.messages,
 maxTokens: maxTokens
 )
 )
 
 let message = try completion.choices.toCollectionOfOne().first.message
 
 _debugPrint(
 prompt: prompt.debugDescription,
 completion: message.body
 .description
 .delimited(by: .quotationMark)
 .delimited(by: "\n")
 )
 
 return AbstractLLM.ChatCompletion(
 prompt: prompt.messages,
 message: try .init(from: message)
 )
 }
 
 private func _validateParameters(
 parameters: AbstractLLM.ChatCompletionParameters,
 model: OpenAI.Model
 ) {
 if let temperature = parameters.temperatureOrTopP?.temperature {
 if temperature > 1.2 {
 runtimeIssue("OpenAI's API doesn't seem to support a temperature higher than 1.2, but it is available on their playground at https://platform.openai.com/playground/chat?models=gpt-4o")
 }
 }
 }
 
 public func completion(
 for prompt: AbstractLLM.ChatPrompt
 ) throws -> AbstractLLM.ChatCompletionStream {
 AbstractLLM.ChatCompletionStream {
 try await self._completion(for: prompt)
 }
 }
 
 private func _completion(
 for prompt: AbstractLLM.ChatPrompt
 ) async throws -> AnyPublisher<AbstractLLM.ChatCompletionStream.Event, Error> {
 var session: OpenAI.ChatCompletionSession! = OpenAI.ChatCompletionSession(client: self)
 
 let messages: [OpenAI.ChatMessage] = try await prompt.messages.asyncMap {
 try await OpenAI.ChatMessage(from: $0)
 }
 let model: OpenAI.Model = try self._model(for: prompt, parameters: nil)
 let parameters: OpenAI.Client.ChatCompletionParameters = try await self._chatCompletionParameters(
 from: prompt.context.completionParameters,
 for: prompt
 )
 
 return try await session
 .complete(
 messages: messages,
 model: model,
 parameters: parameters
 )
 .tryMap { (message: OpenAI.ChatMessage) -> AbstractLLM.ChatCompletionStream.Event in
 AbstractLLM.ChatCompletionStream.Event.completion(
 AbstractLLM.ChatCompletion.Partial(
 message: .init(whole: try AbstractLLM.ChatMessage(from: message)),
 stopReason: nil
 )
 )
 }
 .handleCancelOrCompletion { _ in
 session = nil
 }
 .eraseToAnyPublisher()
 }
 }
 
 */
