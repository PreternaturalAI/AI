//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/26/24.
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension Groq {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        case gemma_7b = "gemma-7b-it"
        case llama3_8b = "llama3-8b-8192"
        case llama3_70b = "llama3-70b-8192"
        case mixtral_8x7b = "mixtral-8x7b-32768"
        
        public var name: String {
            switch self {
                case .gemma_7b:
                    return "Gemma 7b"
                case .llama3_8b:
                    return "LLaMA3 8b"
                case .llama3_70b:
                    return "LLaMA3 70b"
                case .mixtral_8x7b:
                    return "Mixtral 8x7b"
            }
        }
    }
}

// MARK: - Conformances

extension Groq.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Groq.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._Groq, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._Groq,
            name: rawValue,
            revision: nil
        )
    }
}
