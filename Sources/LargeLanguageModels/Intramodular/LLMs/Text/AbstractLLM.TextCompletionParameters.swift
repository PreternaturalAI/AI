//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension AbstractLLM {
    public struct TextCompletionParameters: CompletionParameters {
        public var tokenLimit: TokenLimit
        public var temperatureOrTopP: TemperatureOrTopP? = .temperature(1)
        public var stops: [String]?
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit,
            temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
            stops: [String]? = nil
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperatureOrTopP
            self.stops = stops
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.TextCompletionParameters: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(
            tokenLimit: .max,
            temperatureOrTopP: nil,
            stops: nil
        )
    }
}
