//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import Diagnostics
@_spi(Internal) import LargeLanguageModels
import Merge
import Swallow

extension OpenAI.Client: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: Dependencies {
        var result = Dependencies()
        
        result[\.llm] = self
        result[\.embedding] = self
        
        return result
    }
}

extension OpenAI.Client: LLMRequestHandling {
    private var _debugPrintCompletions: Bool {
        false
    }
    
    public var _availableModels: [ModelIdentifier]? {
        OpenAI.Model.allCases.map({ $0.__conversion() })
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
            messages: prompt.messages.map({ try OpenAI.ChatMessage(from: $0) }),
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
        
        let messages: [OpenAI.ChatMessage] = try prompt.messages.map {
            try OpenAI.ChatMessage(from: $0)
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

extension OpenAI.Client {
    private func _debugPrint(prompt: String, completion: String) {
        guard _debugPrintCompletions else {
            return
        }
        
        guard _isDebugAssertConfiguration else {
            return
        }
        
        let description = String.concatenate(separator: "\n") {
            "=== [PROMPT START] ==="
            prompt.debugDescription
                .delimited(by: .quotationMark)
                .delimited(by: "\n")
            "==== [COMPLETION] ===="
            completion
                .delimited(by: .quotationMark)
                .delimited(by: "\n")
            "==== [PROMPT END] ===="
        }
        
        print(description)
    }
    
    private func _chatCompletionParameters(
        from parameters: (any AbstractLLM.CompletionParameters)?,
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> OpenAI.Client.ChatCompletionParameters {
        let parameters: AbstractLLM.ChatCompletionParameters = try cast(parameters ?? AbstractLLM.ChatCompletionParameters())
        let model: OpenAI.Model = try self._model(
            for: prompt,
            parameters: parameters
        )
        let maxTokens: Int?
        
        do {
            switch (parameters.tokenLimit) {
                case .fixed(let count):
                    maxTokens = count
                case .max, .none:
                    maxTokens = nil
            }
        }
        
        return try OpenAI.Client.ChatCompletionParameters(
            from: parameters,
            model: model,
            messages: prompt.messages,
            maxTokens: maxTokens
        )
    }
    
    private func _model(
        for prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters?
    ) throws -> OpenAI.Model {
        var prompt = prompt
        
        if let modelIdentifierScope = prompt.context.get(\.modelIdentifier) {
            return try OpenAI.Model(from: try! modelIdentifierScope._oneValue)
        }
        
        let result: OpenAI.Model
        
        let containsImage = try prompt.messages.contains(where: { try $0.content._containsImages })
        
        if containsImage {
            result = .chat(.gpt_4_vision_preview)
        } else {
            result = .chat(.gpt_4_turbo)
        }
        
        if result == .chat(.gpt_3_5_turbo) {
            prompt.messages._forEach(mutating: {
                if $0.role == .system {
                    $0 = .init(role: .user, content: $0.content)
                }
            })
        }
        
        return result
    }
    
    private func tokenizer(
        for model: OpenAI.Model
    ) async throws -> OpenAI.Client._Tokenizer {
        try await .init(model: model)
    }
}

extension OpenAI.Client {
    public struct _Tokenizer: PromptLiteralTokenizer {
        public typealias Token = Int
        public typealias Output = [Int]
        
        private let model: OpenAI.Model
        private var base: Tiktoken.Encoding
        
        public init(model: OpenAI.Model) async throws {
            self.model = model
            self.base = try await Tiktoken.encoding(for: model).unwrap()
        }
        
        public func encode(_ input: PromptLiteral) throws -> Output {
            try base.encode(input._stripToText())
        }
        
        public func decode(_ tokens: Output) throws -> PromptLiteral {
            fatalError()
        }
    }
}

// MARK: - Auxiliary

extension ModelIdentifier {
    public init(
        from model: OpenAI.Model.InstructGPT
    ) {
        self.init(provider: .openAI, name: model.rawValue, revision: nil)
    }
    
    public init(
        from model: OpenAI.Model.Chat
    ) {
        self.init(provider: .openAI, name: model.rawValue, revision: nil)
    }
    
    public init(
        from model: OpenAI.Model.Embedding
    ) {
        self.init(provider: .openAI, name: model.rawValue, revision: nil)
    }
}

extension OpenAI.Client.TextCompletionParameters {
    public init(
        from parameters: AbstractLLM.TextCompletionParameters,
        model: OpenAI.Model,
        prompt _: any PromptLiteralConvertible
    ) throws {
        self.init(
            maxTokens: nil,
            temperature: parameters.temperatureOrTopP?.temperature,
            topProbabilityMass: parameters.temperatureOrTopP?.topProbabilityMass,
            stop: parameters.stops.map(Either.right)
        )
    }
}

extension OpenAI.Client.ChatCompletionParameters {
    public init(
        from parameters: AbstractLLM.ChatCompletionParameters,
        model: OpenAI.Model,
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

extension OpenAI.ChatFunctionDefinition {
    public init(
        from function: AbstractLLM.ChatFunctionDefinition
    ) {
        self.init(
            name: function.name,
            description: function.context,
            parameters: function.parameters
        )
    }
}
