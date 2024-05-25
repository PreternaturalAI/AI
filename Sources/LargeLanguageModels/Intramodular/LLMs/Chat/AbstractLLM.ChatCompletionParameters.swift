//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension AbstractLLM {    
    public struct ChatCompletionParameters: CompletionParameters {
        /// The maximum number of tokens to generate shared between the prompt and completion. The exact limit varies by model. Default is max tokens.
        public let tokenLimit: TokenLimit?
        /// Control the randomness of the result
        public let temperatureOrTopP: TemperatureOrTopP?
        /// Stop words / sentences / sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence. (Note: The OpenAI API only accepts up to four stop sequences)
        public let stops: [String]?
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
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit? = nil,
            temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
            stops: [String]? = nil,
            tools: [ChatFunctionDefinition]? 
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
            functions: [ChatFunctionDefinition]?
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperature.map({ .temperature($0) })
            self.stops = stops
            self.functions = functions.map({ IdentifierIndexingArrayOf($0) })
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatCompletionParameters: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(tokenLimit: nil, temperatureOrTopP: nil, stops: nil, functions: nil)
    }
}
