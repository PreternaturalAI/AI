//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension XAI {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        case grokBeta = "grok-beta"
        case grokVisionBeta = "grok-vision-beta"
        
        public var name: String {
            switch self {
                case .grokBeta:
                    return "Grok Beta"
                case .grokVisionBeta:
                    return "Grok Vision Beta"
            }
        }
    }
}

// MARK: - Conformances

extension XAI.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension XAI.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._xAI, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._xAI,
            name: rawValue,
            revision: nil
        )
    }
}
