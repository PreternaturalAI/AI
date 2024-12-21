//
// Copyright (c) Preternatural AI, Inc.
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension TogetherAI {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        // Together Models
        case togetherM2Bert80M2KRetrieval = "togethercomputer/m2-bert-80M-2k-retrieval"
        case togetherM2Bert80M8KRetrieval = "togethercomputer/m2-bert-80M-8k-retrieval"
        case togetherM2Bert80M32KRetrieval = "togethercomputer/m2-bert-80M-32k-retrieval"
        
        // WhereIsAI
        case whereIsAIUAELargeV1 = "WhereIsAI/UAE-Large-V1"
        
        // Beijing Academy of Artificial Intelligence models
        case baaiLargeENV15 = "BAAI/bge-large-en-v1.5"
        case baaiBaseENV15 = "BAAI/bge-base-en-v1.5"
        
        // Sentence Transformer model
        case sentenceBERT = "sentence-transformers/msmarco-bert-base-dot-v5"
        
        // Google BERT
        case googleBERTBaseUncased = "bert-base-uncased"
        
        public var name: String {
            switch self {
            case .togetherM2Bert80M2KRetrieval: 
                return "M2-BERT-80M-2K-Retrieval"
            case .togetherM2Bert80M8KRetrieval: 
                return "M2-BERT-80M-8K-Retrieval"
            case .togetherM2Bert80M32KRetrieval: 
                return "M2-BERT-80M-32K-Retrieval"
            case .whereIsAIUAELargeV1: 
                return "UAE-Large-v1"
            case .baaiLargeENV15: 
                return "BGE-Large-EN-v1.5"
            case .baaiBaseENV15: 
                return "BGE-Base-EN-v1.5"
            case .sentenceBERT: 
                return "Sentence-BERT"
            case .googleBERTBaseUncased: 
                return "BERT"
            }
        }
        
        public var modelSize: Int {
            switch self {
            case .togetherM2Bert80M2KRetrieval, .togetherM2Bert80M8KRetrieval, .togetherM2Bert80M32KRetrieval:
                return 80_000_000
            case .whereIsAIUAELargeV1, .baaiLargeENV15:
                return 326_000_000
            case .baaiBaseENV15:
                return 102_000_000
            case .sentenceBERT, .googleBERTBaseUncased:
                return 110_000_000
            }
        }
        
        public var embeddingDimension: Int {
            switch self {
            case .togetherM2Bert80M2KRetrieval, .togetherM2Bert80M8KRetrieval, .togetherM2Bert80M32KRetrieval:
                return 768
            case .whereIsAIUAELargeV1, .baaiLargeENV15:
                return 1024
            case .baaiBaseENV15, .sentenceBERT, .googleBERTBaseUncased:
                return 768
            }
        }
        
        public var contextWindow: Int {
            switch self {
            case .togetherM2Bert80M2KRetrieval: 
                return 2048
            case .togetherM2Bert80M8KRetrieval: 
                return 8192
            case .togetherM2Bert80M32KRetrieval: 
                return 32768
            case .whereIsAIUAELargeV1, .baaiLargeENV15, .baaiBaseENV15, .sentenceBERT, .googleBERTBaseUncased:
                return 512
            }
        }
    }
}

// MARK: - Conformances

extension TogetherAI.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension TogetherAI.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._TogetherAI, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._TogetherAI,
            name: rawValue,
            revision: nil
        )
    }
}
