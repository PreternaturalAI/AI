//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import Diagnostics
@_spi(Internal) import LargeLanguageModels
import Merge
import Swallow

extension OpenAI.APIClient: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: Dependencies {
        var result = Dependencies()
        
        result[\.llmServices] = self
        result[\.textEmbeddingsProvider] = self
        
        return result
    }
}

extension OpenAI.APIClient: LLMRequestHandling {
    private var _debugPrintCompletions: Bool {
        false
    }
    
    public var _availableModels: [_MLModelIdentifier]? {
        OpenAI.Model.allCases.map({ $0.__conversion() })
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
        let model: OpenAI.Model = try self._model(for: prompt, parameters: nil, heuristics: nil)
        let parameters: OpenAI.APIClient.ChatCompletionParameters = try await self._chatCompletionParameters(
            from: prompt.context.completionParameters,
            for: prompt,
            completionHeuristics: nil
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
        parameters: AbstractLLM.ChatCompletionParameters,
        heuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> AbstractLLM.ChatCompletion {
        let model = try self._model(for: prompt, parameters: parameters, heuristics: heuristics)
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
        
        return .init(message: try .init(from: message))
    }
    
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
        for prompt: AbstractLLM.ChatPrompt,
        completionHeuristics: AbstractLLM.CompletionHeuristics
    ) async throws -> OpenAI.APIClient.ChatCompletionParameters {
        let parameters: AbstractLLM.ChatCompletionParameters = try cast(parameters ?? AbstractLLM.ChatCompletionParameters())
        let model: OpenAI.Model = try self._model(
            for: prompt,
            parameters: parameters,
            heuristics: completionHeuristics
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
        
        return try OpenAI.APIClient.ChatCompletionParameters(
            from: parameters,
            model: model,
            messages: prompt.messages,
            maxTokens: maxTokens
        )
    }
    
    private func _model(
        for prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters?,
        heuristics: AbstractLLM.CompletionHeuristics?
    ) throws -> OpenAI.Model {
        var prompt = prompt
        
        if let modelIdentifierScope = prompt.context.get(\.modelIdentifier) {
            if let modelIdentifier = modelIdentifierScope._oneValue {
                return try OpenAI.Model(from: modelIdentifier)
            } else {
                fatalError(.unimplemented)
            }
        }
        
        let result: OpenAI.Model
        
        let containsImage = try prompt.messages.contains(where: { try $0.content._containsImages })
        
        if containsImage {
            result = .chat(.gpt_4_vision_preview)
        } else if (heuristics?.wantsMaximumReasoning ?? false) {
            result = .chat(.gpt_4_1106_preview)
        } else {
            result = .chat(.gpt_3_5_turbo)
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
    ) async throws -> OpenAI.APIClient._Tokenizer {
        try await .init(model: model)
    }
}

extension OpenAI.APIClient {
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

extension OpenAI.APIClient: TextEmbeddingsRequestHandling {
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        guard !request.input.isEmpty else {
            return TextEmbeddings(
                model: .init(from: OpenAI.Model.Embedding.ada),
                data: []
            )
        }
        
        let model = request.model ?? _MLModelIdentifier(from: OpenAI.Model.Embedding.ada)
        let embeddingModel = try OpenAI.Model.Embedding(rawValue: model.name).unwrap()
        
        let embeddings = try await createEmbeddings(
            model: embeddingModel,
            for: request.input
        ).data
        
        try _tryAssert(request.input.count == embeddings.count)
        
        return TextEmbeddings(
            model: .init(from: OpenAI.Model.Embedding.ada),
            data: request.input.zip(embeddings).map {
                TextEmbeddings.Element(
                    text: $0,
                    embedding: $1.embedding
                )
            }
        )
    }
}

// MARK: - Auxiliary

extension _MLModelIdentifier {
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

extension OpenAI.APIClient.TextCompletionParameters {
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

extension OpenAI.APIClient.ChatCompletionParameters {
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
