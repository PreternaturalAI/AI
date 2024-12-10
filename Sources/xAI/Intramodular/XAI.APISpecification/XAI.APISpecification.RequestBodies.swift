import Foundation
import OpenAI

extension XAI.APISpecification.RequestBodies {
    public struct CreateChatCompletion: Codable, Hashable {
        private enum CodingKeys: String, CodingKey {
            case user
            case messages
            case functions = "functions"
            case functionCallingStrategy = "function_call"
            case model
            case temperature
            case topProbabilityMass = "top_p"
            case choices = "n"
            case stream
            case stop
            case maxTokens = "max_tokens"
            case presencePenalty = "presence_penalty"
            case frequencyPenalty = "frequency_penalty"
            case logprobs = "logprobs"
            case topLogprobs = "top_logprobs"
            case logitBias = "logit_bias"
            case responseFormat = "response_format"
            case seed = "seed"
        }
        
        let messages: [OpenAI.ChatMessage]
        let model: XAI.Model
        let frequencyPenalty: Double?
        let logitBias: [String: Int]?
        let logprobs: Bool?
        let topLogprobs: Int?
        let maxTokens: Int?
        let choices: Int?
        let presencePenalty: Double?
        let responseFormat: OpenAI.ChatCompletion.ResponseFormat?
        let seed: String?
        let stop: [String]?
        let stream: Bool?
        let temperature: Double?
        let topProbabilityMass: Double?
        let user: String?
        let functions: [OpenAI.ChatFunctionDefinition]?
        let functionCallingStrategy: OpenAI.FunctionCallingStrategy?
        
        public init(
            messages: [OpenAI.ChatMessage],
            model: XAI.Model,
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
            stream: Bool? = nil,
            temperature: Double? = nil,
            topProbabilityMass: Double? = nil,
            user: String? = nil,
            functions: [OpenAI.ChatFunctionDefinition]? = nil,
            functionCallingStrategy: OpenAI.FunctionCallingStrategy? = nil
        ) {
            self.messages = messages
            self.model = model
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
            self.stream = stream
            self.temperature = temperature
            self.topProbabilityMass = topProbabilityMass
            self.user = user
            self.functions = functions
            self.functionCallingStrategy = functionCallingStrategy
        }
        
        public init(
            user: String?,
            messages: [OpenAI.ChatMessage],
            functions: [OpenAI.ChatFunctionDefinition]?,
            functionCallingStrategy: OpenAI.FunctionCallingStrategy?,
            model: XAI.Model,
            temperature: Double?,
            topProbabilityMass: Double?,
            choices: Int?,
            stream: Bool?,
            stop: [String]?,
            maxTokens: Int?,
            presencePenalty: Double?,
            frequencyPenalty: Double?,
            responseFormat: OpenAI.ChatCompletion.ResponseFormat?
        ) {
            self.user = user
            self.messages = messages
            self.functions = functions.nilIfEmpty()
            self.functionCallingStrategy = functions == nil ? nil : functionCallingStrategy
            self.model = model
            self.temperature = temperature
            self.topProbabilityMass = topProbabilityMass
            self.choices = choices
            self.stream = stream
            self.stop = stop
            self.maxTokens = maxTokens
            self.presencePenalty = presencePenalty
            self.frequencyPenalty = frequencyPenalty
            self.logitBias = nil
            self.logprobs = nil
            self.topLogprobs = nil
            self.responseFormat = responseFormat
            self.seed = nil
        }
    }
}

