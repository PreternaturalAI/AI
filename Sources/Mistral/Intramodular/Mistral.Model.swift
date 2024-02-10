//
// Copyright (c) Vatsal Manot
//

import CoreGML
import CorePersistence
import LargeLanguageModels
import Swallow

extension Mistral {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        case mistral_tiny = "mistral-tiny"
        case mistral_small = "mistral-small"
        case mistral_medium = "mistral-medium"
        
        public var name: String {
            switch self {
                case .mistral_tiny:
                    return "Tiny"
                case .mistral_small:
                    return "Small"
                case .mistral_medium:
                    return "Medium"
            }
        }
    }
}

// MARK: - Conformances

extension Mistral.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Mistral.Model: _GMLModelIdentifierRepresentable {
    public init(from identifier: _GMLModelIdentifier) throws {
        guard identifier.provider == ._Mistral, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> _GMLModelIdentifier {
        _GMLModelIdentifier(
            provider: ._Mistral,
            name: rawValue,
            revision: nil
        )
    }
}
