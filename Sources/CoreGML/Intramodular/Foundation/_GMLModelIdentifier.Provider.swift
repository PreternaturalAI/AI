//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

@available(*, deprecated, renamed: "_GMLModelIdentifier.Provider")
public typealias MLModelProvider = _GMLModelIdentifier.Provider

extension _GMLModelIdentifier {
    @HadeanIdentifier("bagog-golir-jisap-mozop")
    @RuntimeDiscoverable
    public enum Provider: Hashable, Sendable {
        case _Anthropic
        case _Apple
        case _Mistral
        case _Ollama
        case _OpenAI
        
        case unknown(String)
        
        public static var apple: Self {
            Self._Apple
        }
        
        public static var openAI: Self {
            Self._OpenAI
        }
        
        public static var anthropic: Self {
            Self._Anthropic
        }
    }
}

// MARK: - Conformances

extension _GMLModelIdentifier.Provider: CustomStringConvertible {
    public var description: String {
        switch self {
            case ._Anthropic:
                return "Anthropic"
            case ._Apple:
                return "Apple"
            case ._Mistral:
                return "Mistral"
            case ._Ollama:
                return "Ollama"
            case ._OpenAI:
                return "OpenAI"
            case .unknown(let provider):
                return provider
        }
    }
}

extension _GMLModelIdentifier.Provider: RawRepresentable {
    public var rawValue: String {
        switch self {
            case ._Anthropic:
                return "anthropic"
            case ._Apple:
                return "apple"
            case ._Mistral:
                return "mistral"
            case ._Ollama:
                return "ollama"
            case ._OpenAI:
                return "openai"
            case .unknown(let provider):
                return provider
        }
    }
    
    public init(rawValue: String) {
        switch rawValue {
            case Self._Anthropic.rawValue:
                self = ._Anthropic
            case Self._Apple.rawValue:
                self = ._Apple
            case Self._Mistral.rawValue:
                self = ._Mistral
            case Self._OpenAI.rawValue:
                self = ._OpenAI
            default:
                self = .unknown(rawValue)
        }
    }
}

extension _GMLModelIdentifier.Provider: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
