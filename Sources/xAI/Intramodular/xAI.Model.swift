

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension xAI {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        case grok_beta = "grok-beta"
        case grok_vision_beta = "grok-vision-beta"
        
        public var name: String {
            switch self {
                case .grok_beta:
                    return "Grok Beta"
                case .grok_vision_beta:
                    return "Grok Vision Beta"
            }
        }
    }
}

// MARK: - Conformances

extension xAI.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension xAI.Model: ModelIdentifierRepresentable {
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
