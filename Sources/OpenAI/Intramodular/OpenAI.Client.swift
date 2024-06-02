//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import NetworkKit
import Swift

public final class _OpenAI_Client: HTTPClient, _StaticSwift.Namespace {
    public let interface: OpenAI.APISpecification
    public let session: HTTPSession
    
    public init(interface: OpenAI.APISpecification, session: HTTPSession) {
        self.interface = interface
        self.session = session
    }
    
    public convenience init(apiKey: String?) {
        var apiKey = apiKey
        
        if apiKey == nil, ProcessInfo.processInfo._isRunningWithinXCTest {
            #try(.optimistic) {
                apiKey = try _PreternaturalDotFile.key(for: .openAI)
            }
        }
        
        self.init(
            interface: .init(configuration: .init(apiKey: apiKey)),
            session: .shared
        )
    }
    
    public convenience init(configuration: OpenAI.APISpecification.Configuration) {
        self.init(interface: .init(configuration: configuration), session: .shared)
    }
}

extension OpenAI {
    public typealias Client = _OpenAI_Client

    @available(*, deprecated, renamed: "OpenAI.Client")
    public typealias APIClient = _OpenAI_Client
}

extension OpenAI.Client {
    public func createCompletion(
        model: OpenAI.Model,
        prompt: String,
        parameters: OpenAI.Client.TextCompletionParameters
    ) async throws -> OpenAI.TextCompletion {
        let requestBody = OpenAI.APISpecification.RequestBodies.CreateCompletion(
            prompt: .left(prompt),
            model: model,
            parameters: parameters,
            stream: false
        )
        
        return try await run(\.createCompletions, with: requestBody)
    }
    
    public func createCompletion(
        model: OpenAI.Model,
        prompts: [String],
        parameters: OpenAI.Client.TextCompletionParameters
    ) async throws -> OpenAI.TextCompletion {
        let requestBody = OpenAI.APISpecification.RequestBodies.CreateCompletion(
            prompt: .right(prompts),
            model: model,
            parameters: parameters,
            stream: false
        )
        
        return try await run(\.createCompletions, with: requestBody)
    }
    
    public func createChatCompletion(
        messages: [OpenAI.ChatMessage],
        model: OpenAI.Model,
        parameters: OpenAI.Client.ChatCompletionParameters
    ) async throws -> OpenAI.ChatCompletion {
        let requestBody = OpenAI.APISpecification.RequestBodies.CreateChatCompletion(
            messages: messages,
            model: model,
            parameters: parameters,
            stream: false
        )
        
        return try await run(\.createChatCompletions, with: requestBody)
    }
    
    public func createChatCompletion(
        messages: [OpenAI.ChatMessage],
        model: OpenAI.Model.Chat,
        parameters: OpenAI.Client.ChatCompletionParameters
    ) async throws -> OpenAI.ChatCompletion {
        try await createChatCompletion(
            messages: messages,
            model: .chat(model),
            parameters: parameters
        )
    }
    
    public func createTextOrChatCompletion(
        prompt: String,
        system: String?,
        model: OpenAI.Model,
        temperature: Double?,
        topProbabilityMass: Double?,
        maxTokens: Int?
    ) async throws -> Either<OpenAI.TextCompletion, OpenAI.ChatCompletion> {
        switch model {
            case .chat(let model): do {
                let messages: [OpenAI.ChatMessage] = system.map({ [.system($0), .user(prompt)] }) ?? [.user(prompt)]
                
                let result = try await createChatCompletion(
                    messages: messages,
                    model: model,
                    parameters: .init(temperature: temperature, topProbabilityMass: topProbabilityMass, maxTokens: maxTokens)
                )
                
                return .right(result)
            }
            case .instructGPT: do {
                let result = try await createCompletion(
                    model: model,
                    prompt: prompt,
                    parameters: .init(maxTokens: maxTokens, temperature: temperature, topProbabilityMass: topProbabilityMass)
                )
                
                return .left(result)
            }
            default:
                throw _PlaceholderError()
        }
    }
}

extension OpenAI.Client {
    @discardableResult
    public func createRun(
        threadID: OpenAI.Thread.ID,
        assistantID: String,
        model: OpenAI.Model? = nil,
        instructions: String? = nil,
        tools: [OpenAI.Tool]?,
        metadata: [String: String]? = nil
    ) async throws -> OpenAI.Run {
        let result = try await run(
            \.createRun,
             with: (
                thread: threadID,
                requestBody: .init(
                    assistantID: assistantID,
                    model: model,
                    instructions: instructions,
                    tools: tools,
                    metadata: metadata
                )
             )
        )
        
        return result
    }
    
    public func retrieve(
        run: OpenAI.Run.ID,
        thread: OpenAI.Thread.ID
    ) async throws -> OpenAI.Run {
        try await self.run(\.retrieveRunForThread, with: (thread, run))
    }
}

// MARK: - Conformances

extension OpenAI.Client: _MaybeAsyncProtocol {
    public func _resolveToNonAsync() async throws -> Self {
        self
    }
}

extension OpenAI.Client: PersistentlyRepresentableType {
    public static var persistentTypeRepresentation: some IdentityRepresentation {
        _MIServiceTypeIdentifier._OpenAI
    }
}

// MARK: - Auxiliary

extension OpenAI.Client {
    public struct TextCompletionParameters: Codable, Hashable {
        public var suffix: String?
        public var maxTokens: Int?
        public var temperature: Double?
        public var topProbabilityMass: Double?
        public var n: Int
        public var logprobs: Int?
        public var stop: Either<String, [String]>?
        public var presencePenalty: Double?
        public var frequencyPenalty: Double?
        public var bestOf: Int?
        public var logitBias: [String: Int]?
        public var user: String?
        
        public init(
            suffix: String? = nil,
            maxTokens: Int? = 16,
            temperature: Double? = 1,
            topProbabilityMass: Double? = 1,
            n: Int = 1,
            logprobs: Int? = nil,
            echo: Bool? = false,
            stop: Either<String, [String]>? = nil,
            presencePenalty: Double? = 0,
            frequencyPenalty: Double? = 0,
            bestOf: Int? = 1,
            logitBias: [String: Int]? = nil,
            user: String? = nil
        ) {
            self.suffix = suffix
            self.maxTokens = maxTokens
            self.temperature = temperature
            self.topProbabilityMass = topProbabilityMass
            self.n = n
            self.logprobs = logprobs
            self.stop = stop?.nilIfEmpty()
            self.presencePenalty = presencePenalty
            self.frequencyPenalty = frequencyPenalty
            self.bestOf = bestOf
            self.logitBias = logitBias
            self.user = user
        }
    }
    
    public struct ChatCompletionParameters: Codable, Hashable, Sendable {
        public let frequencyPenalty: Double?
        public let logitBias: [String: Int]?
        public let logprobs: Bool?
        public let topLogprobs: Int?
        public let maxTokens: Int?
        public let choices: Int?
        public let presencePenalty: Double?
        public let responseFormat: OpenAI.ChatCompletion.ResponseFormat?
        public let seed: String?
        public let stop: [String]?
        public let temperature: Double?
        public let topProbabilityMass: Double?
        public let user: String?
        public let functions: [OpenAI.ChatFunctionDefinition]?
        public let functionCallingStrategy: OpenAI.FunctionCallingStrategy?
        
        public init(
            frequencyPenalty: Double? = nil,
            logitBias: [String : Int]? = nil,
            logprobs: Bool? = nil,
            topLogprobs: Int? = nil,
            maxTokens: Int? = nil,
            choices: Int? = nil,
            presencePenalty: Double? = nil,
            responseFormat: OpenAI.ChatCompletion.ResponseFormat? = nil,
            seed: String? = nil,
            stop: [String]? = nil,
            temperature: Double? = nil,
            topProbabilityMass: Double? = nil,
            user: String? = nil,
            functions: [OpenAI.ChatFunctionDefinition]? = nil,
            functionCallingStrategy: OpenAI.FunctionCallingStrategy? = nil
        ) {
            self.frequencyPenalty = frequencyPenalty
            self.logitBias = logitBias
            self.logprobs = logprobs
            self.topLogprobs = topLogprobs
            self.maxTokens = maxTokens
            self.choices = choices
            self.presencePenalty = presencePenalty
            self.responseFormat = responseFormat
            self.seed = seed
            self.stop = stop
            self.temperature = temperature
            self.topProbabilityMass = topProbabilityMass
            self.user = user
            self.functions = functions
            self.functionCallingStrategy = functionCallingStrategy
        }

    }
}

extension OpenAI.Client.ChatCompletionParameters {
    public init(
        user: String? = nil,
        temperature: Double? = nil,
        topProbabilityMass: Double? = nil,
        choices: Int? = nil,
        stop: [String]? = nil,
        maxTokens: Int? = nil,
        presencePenalty: Double? = nil,
        frequencyPenalty: Double? = nil,
        functions: [OpenAI.ChatFunctionDefinition]? = nil,
        functionCallingStrategy: OpenAI.FunctionCallingStrategy? = nil
    ) {
        self.user = user
        self.temperature = temperature
        self.topProbabilityMass = topProbabilityMass
        self.choices = choices
        self.stop = stop.nilIfEmpty()
        self.maxTokens = maxTokens
        self.presencePenalty = presencePenalty
        self.frequencyPenalty = frequencyPenalty
        self.functions = functions
        self.functionCallingStrategy = functionCallingStrategy
        
        self.logitBias = nil
        self.logprobs = nil
        self.topLogprobs = nil
        self.responseFormat = nil
        self.seed = nil
    }
}
