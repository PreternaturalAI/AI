//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension ModelIdentifier {
    @HadeanIdentifier("bagog-golir-jisap-mozop")
    @RuntimeDiscoverable
    public enum Provider: Hashable, Sendable {
        case _Anthropic
        case _Apple
        case _Fal
        case _Mistral
        case _Groq
        case _xAI
        case _Ollama
        case _OpenAI
        case _Gemini
        case _Perplexity
        case _Jina
        case _VoyageAI
        case _Cohere
        case _ElevenLabs
        case _TogetherAI
        
        case unknown(String)
        
        public static var apple: Self {
            Self._Apple
        }
        
        public static var fal: Self {
            self._Fal
        }
        
        public static var openAI: Self {
            Self._OpenAI
        }
        
        public static var anthropic: Self {
            Self._Anthropic
        }
        
        public static var groq: Self {
            Self._Groq
        }
        
        public static var xAI: Self {
            Self._xAI
        }
        
        public static var gemini: Self {
            Self._Gemini
        }
        
        public static var perplexity: Self {
            Self._Perplexity
        }
        
        public static var jina: Self {
            Self._Jina
        }
        
        public static var voyageAI: Self {
            Self._VoyageAI
        }
        
        public static var cohere: Self {
            Self._Cohere
        }
        
        public static var elevenLabs: Self {
            Self._ElevenLabs
        }
        
        public static var togetherAI: Self {
            Self._TogetherAI
        }
    }
}

// MARK: - Conformances

extension ModelIdentifier.Provider: CustomStringConvertible {
    public var description: String {
        switch self {
        case ._Anthropic:
            return "Anthropic"
        case ._Apple:
            return "Apple"
        case ._Fal:
            return "Fal"
        case ._Mistral:
            return "Mistral"
        case ._Groq:
            return "Groq"
        case ._xAI:
            return "xAI"
        case ._Ollama:
            return "Ollama"
        case ._OpenAI:
            return "OpenAI"
        case ._Gemini:
            return "Gemini"
        case ._Perplexity:
            return "Perplexity"
        case ._Jina:
            return "Perplexity"
        case ._VoyageAI:
            return "VoyageAI"
        case ._Cohere:
            return "Cohere"
        case ._ElevenLabs:
            return "ElevenLabs"
        case ._TogetherAI:
            return "TogetherAI"
        case .unknown(let provider):
            return provider
        }
    }
}

extension ModelIdentifier.Provider: RawRepresentable {
    public var rawValue: String {
        switch self {
        case ._Anthropic:
            return "anthropic"
        case ._Apple:
            return "apple"
        case ._Fal:
            return "fal"
        case ._Mistral:
            return "mistral"
        case ._Groq:
            return "groq"
        case ._xAI:
            return "xai"
        case ._Ollama:
            return "ollama"
        case ._OpenAI:
            return "openai"
        case ._Gemini:
            return "gemini"
        case ._Perplexity:
            return "perplexity"
        case ._Jina:
            return "jina"
        case ._VoyageAI:
            return "voyageai"
        case ._Cohere:
            return "cohere"
        case ._ElevenLabs:
            return "elevenlabs"
        case ._TogetherAI:
            return "togetherai"
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
        case Self._Fal.rawValue:
            self = ._Fal
        case Self._Mistral.rawValue:
            self = ._Mistral
        case Self._Groq.rawValue:
            self = ._Groq
        case Self._xAI.rawValue:
            self = ._xAI
        case Self._OpenAI.rawValue:
            self = ._OpenAI
        case Self._Gemini.rawValue:
            self = ._Gemini
        case Self._Perplexity.rawValue:
            self = ._Perplexity
        case Self._Jina.rawValue:
            self = ._Jina
        case Self._VoyageAI.rawValue:
            self = ._VoyageAI
        case Self._Cohere.rawValue:
            self = ._Cohere
        case Self._ElevenLabs.rawValue:
            self = ._ElevenLabs
        case Self._TogetherAI.rawValue:
            self = ._TogetherAI
        default:
            self = .unknown(rawValue)
        }
    }
}

extension ModelIdentifier.Provider: Codable {
    public init(from decoder: Decoder) throws {
        try self.init(rawValue: String(from: decoder))
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}
