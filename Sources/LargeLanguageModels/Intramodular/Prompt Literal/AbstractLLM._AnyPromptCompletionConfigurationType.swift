//
// Copyright (c) Vatsal Manot
//

import Swallow

extension AbstractLLM {
    @_spi(Internal)
    public protocol _AnyPromptCompletionConfigurationType: Sendable {
        var temperatureOrTopP: AbstractLLM.TemperatureOrTopP? { get }
        var stops: [String] { get }
    }
}
