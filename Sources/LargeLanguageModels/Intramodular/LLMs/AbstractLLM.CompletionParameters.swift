//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Foundation
import Swallow

extension AbstractLLM {
    public protocol CompletionParameters: Codable, Hashable, Sendable {
        
    }

    public enum TokenLimit: Codable, Hashable, Sendable {
        case max
        case fixed(Int)
        
        public var fixedValue: Int? {
            guard case .fixed(let value) = self else {
                return nil
            }
            
            return value
        }
    }
    
    /// Either temperature or top-p should be used, both cannot be specified at the same time.
    public enum TemperatureOrTopP: Codable, Hashable, Sendable {
        /// Number between 0 and 2, with 1 as default. Lowering temperature results in less random completions. As the temperature approaches zero, the model will become deterministic and repetitive. Higher values like 1.2 will make the output more random.
        case temperature(Double)
        /// Number between 0 and 1, with 1 as the default. An alternative to sampling with temperature, called nucleus sampling, where the model considers the results of the tokens with top_p probability mass. So 0.1 means only the tokens comprising the top 10% probability mass are considered.
        case topProbabilityMass(Double)
        
        public var temperature: Double? {
            guard case .temperature(let value) = self else {
                return nil
            }
            
            return value
        }
        
        public var topProbabilityMass: Double? {
            guard case .topProbabilityMass(let value) = self else {
                return nil
            }
            
            return value
        }
    }
}

extension AbstractLLM {
    /// Completion parameters shared between text and chat LLM inference.
    public struct ChatOrTextCompletionParameters: AbstractLLM.CompletionParameters {
        public var tokenLimit: TokenLimit?
        public var temperatureOrTopP: AbstractLLM.TemperatureOrTopP?
        public var stopSequences: [String] = []
        public var maxTokens: AbstractLLM.TokenLimit
        public var presencePenalty: Double?
        public var frequencyPenalty: Double?
    }
}
