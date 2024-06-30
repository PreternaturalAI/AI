//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension Jina {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        
        /// On par with OpenAI's text-embedding-ada002
        case embeddingsV2BaseEn = "jina-embeddings-v2-base-en"
        case embeddingsV2SmallEn = "jina-embeddings-v2-small-en"
        
        /// German-English bilingual embeddings with SOTA performance
        case embeddingsV2BaseDe = "jina-embeddings-v2-base-de"
        
        /// Spanish-English bilingual embeddings with SOTA performance
        case embeddingsV2BaseEs = "jina-embeddings-v2-base-es"
        
        /// Chinese-English bilingual embeddings with SOTA performance
        case embeddingsV2BaseZh = "jina-embeddings-v2-base-zh"
        
        /// Optimized for code and docstring search
        case embeddingsV2BaseCode = "jina-embeddings-v2-base-code"
        
        
        public var name: String {
            switch self {
            case .embeddingsV2BaseEn:
                return "Jina English Base Model (v2)"
            case .embeddingsV2SmallEn:
                return "Jina English Small Model (v2)"
            case .embeddingsV2BaseDe:
                return "Jina German Base Model (v2)"
            case .embeddingsV2BaseEs:
                return "Jina Spanish Base Model (v2)"
            case .embeddingsV2BaseZh:
                return "Jina Chinese Base Model (v2)"
            case .embeddingsV2BaseCode:
                return "Jina Code Base Model (v2)"
            }
        }
        
        public var size: Int {
            switch self {
            case .embeddingsV2BaseEn: 
                return 137_000_000
            case .embeddingsV2SmallEn: 
                return 33_000_000
            case .embeddingsV2BaseDe: 
                return 161_000_000
            case .embeddingsV2BaseEs: 
                return 161_000_000
            case .embeddingsV2BaseZh: 
                return 161_000_000
            case .embeddingsV2BaseCode: 
                return 137_000_000
            }
        }
        
        public var dimensions: Int {
            switch self {
            case .embeddingsV2BaseEn: 
                return 768
            case .embeddingsV2SmallEn: 
                return 512
            case .embeddingsV2BaseDe: 
                return 768
            case .embeddingsV2BaseEs: 
                return 768
            case .embeddingsV2BaseZh: 
                return 768
            case .embeddingsV2BaseCode: 
                return 768
            }
        }
    }
}

// MARK: - Conformances

extension Jina.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Jina.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._Jina, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._Jina,
            name: rawValue,
            revision: nil
        )
    }
}

