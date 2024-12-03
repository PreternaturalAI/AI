//
// Copyright (c) Vatsal Manot
//

import Foundation
import LargeLanguageModels
import NetworkKit

extension OpenAI.Client {
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

extension OpenAI.APISpecification.RequestBodies.CreateChatCompletion {
    public init(
        messages: [OpenAI.ChatMessage],
        model: OpenAI.Model,
        parameters: OpenAI.Client.ChatCompletionParameters,
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
