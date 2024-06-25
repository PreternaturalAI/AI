//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension Cohere {
    public enum Model: CaseIterable, Codable, Hashable, Named, Sendable {
        /// Defaults to embed-english-v2.0
        /// Smaller "light" models are faster, while larger models will perform better.
        case embedEnglishV3
        case embedMultilingualV3
        case embedEnglishLightV3
        case embedMultilingualLightV3
        case embedEnglishV2
        case embedEnglishLightV2
        case embedMultilingualV2
        
        /// Custom models can also be supplied with their full ID.
        case custom(String)
        
        public var rawValue: String {
            switch self {
            case .embedEnglishV3: return "embed-english-v3.0"
            case .embedMultilingualV3: return "embed-multilingual-v3.0"
            case .embedEnglishLightV3: return "embed-english-light-v3.0"
            case .embedMultilingualLightV3: return "embed-multilingual-light-v3.0"
            case .embedEnglishV2: return "embed-english-v2.0"
            case .embedEnglishLightV2: return "embed-english-light-v2.0"
            case .embedMultilingualV2: return "embed-multilingual-v2.0"
            case .custom(let modelID): return modelID
            }
        }
        
        public init(rawValue: String) {
            switch rawValue {
            case "embed-english-v3.0": self = .embedEnglishV3
            case "embed-multilingual-v3.0": self = .embedMultilingualV3
            case "embed-english-light-v3.0": self = .embedEnglishLightV3
            case "embed-multilingual-light-v3.0": self = .embedMultilingualLightV3
            case "embed-english-v2.0": self = .embedEnglishV2
            case "embed-english-light-v2.0": self = .embedEnglishLightV2
            case "embed-multilingual-v2.0": self = .embedMultilingualV2
            default: self = .custom(rawValue)
            }
        }

        public var name: String {
            switch self {
            case .embedEnglishV3: return "English Embedding v3.0"
            case .embedMultilingualV3: return "Multilingual Embedding v3.0"
            case .embedEnglishLightV3: return "English Light Embedding v3.0"
            case .embedMultilingualLightV3: return "Multilingual Light Embedding v3.0"
            case .embedEnglishV2: return "English Embedding v2.0"
            case .embedEnglishLightV2: return "English Light Embedding v2.0"
            case .embedMultilingualV2: return "Multilingual Embedding v2.0"
            case .custom(let modelID): return "Custom Model: \(modelID)"
            }
        }
        
        
        public static var allCases: [Cohere.Model] {
            return [
                .embedEnglishV3,
                .embedMultilingualV3,
                .embedEnglishLightV3,
                .embedMultilingualLightV3,
                .embedEnglishV2,
                .embedEnglishLightV2,
                .embedMultilingualV2
            ]
        }

        public var dimensions: Int {
            switch self {
            case .embedEnglishV3, .embedMultilingualV3:
                return 1024
            case .embedEnglishLightV3, .embedMultilingualLightV3:
                return 384
            case .embedEnglishV2:
                return 4096
            case .embedEnglishLightV2:
                return 1024
            case .embedMultilingualV2:
                return 768
            case .custom:
                return 0  // Unknown dimension for custom models
            }
        }
    }
}
// MARK: - Conformances

extension Cohere.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Cohere.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._Cohere, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        self = Self(rawValue: identifier.name)
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._Cohere,
            name: rawValue,
            revision: nil
        )
    }
}
