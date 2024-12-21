//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Foundation
import Swallow

extension AbstractLLM {    
    public struct ChatCompletionParameters: CompletionParameters {
        /// The maximum number of tokens to generate shared between the prompt and completion. The exact limit varies by model. Default is max tokens.
        public var tokenLimit: TokenLimit?
        /// Control the randomness of the result
        public var temperatureOrTopP: TemperatureOrTopP?
        /// Stop words / sentences / sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence. (Note: The OpenAI API only accepts up to four stop sequences)
        public var stopSequences: [String]?
        /// Only for ChatGPT, Anthropic and other models that support function calling.
        public var functions: IdentifierIndexingArrayOf<ChatFunctionDefinition>?
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit? = nil,
            temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
            stops: [String]? = nil,
            functions: [ChatFunctionDefinition]? = nil
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperatureOrTopP
            self.stops = stops
            self.functions = functions.map({ IdentifierIndexingArrayOf($0) })
        }
    }
}

// MARK: - Initializers

extension AbstractLLM.ChatCompletionParameters {
    public init(
        tokenLimit: AbstractLLM.TokenLimit? = nil,
        temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
        stops: [String]? = nil,
        tools: [AbstractLLM.ChatFunctionDefinition]?
    ) {
        self.tokenLimit = tokenLimit
        self.temperatureOrTopP = temperatureOrTopP
        self.stops = stops
        self.functions = tools.map({ IdentifierIndexingArrayOf($0) })
    }
    
    public init(
        tokenLimit: AbstractLLM.TokenLimit?,
        temperature: Double?,
        stops: [String]?,
        functions: [AbstractLLM.ChatFunctionDefinition]?
    ) {
        self.tokenLimit = tokenLimit
        self.temperatureOrTopP = temperature.map({ .temperature($0) })
        self.stops = stops
        self.functions = functions.map({ IdentifierIndexingArrayOf($0) })
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatCompletionParameters: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(tokenLimit: nil, temperatureOrTopP: nil, stops: nil, functions: nil)
    }
}

// MARK: - Deprecated

extension AbstractLLM.ChatCompletionParameters {
    public var stops: [String]? {
        get {
            self.stopSequences
        } set {
            self.stopSequences = newValue
        }
    }
}
