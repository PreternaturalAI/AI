//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

public protocol _TogetherAI_ModelType: Codable, Hashable, RawRepresentable, Sendable where RawValue == String {
    var contextSize: Int { get throws }
}

extension TogetherAI {
    public typealias _ModelType = _TogetherAI_ModelType
}

extension TogetherAI {
    public enum Model: CaseIterable, _TogetherAI_ModelType, Hashable {
        public private(set) static var allCases: [Model] = {
            var result: [Model] = []
            
            result += Embedding.allCases.map({ Self.embedding($0 )})
            result += Completion.allCases.map({ Self.completion($0) })
            
            return result
        }()
        
        case completion(Completion)
        case embedding(Embedding)
        case unknown(String)
        
        public var name: String {
            if let base = (base as? any Named) {
                return base.name.description
            } else {
                return base.rawValue
            }
        }
        
        private var base: any TogetherAI._ModelType {
            switch self {
            case .completion(let value):
                return value
            case .embedding(let value):
                return value
            case .unknown:
                assertionFailure(.unimplemented)
                
                return self
            }
        }
        
        public var contextSize: Int {
            get throws {
                try base.contextSize
            }
        }
    }
}

extension TogetherAI.Model {
    public enum Embedding: String, TogetherAI._ModelType, CaseIterable {
        
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
        
        public var contextSize: Int {
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
        
        public init?(rawValue: String) {
            switch rawValue {
            case "togethercomputer/m2-bert-80M-2k-retrieval":
                self = .togetherM2Bert80M2KRetrieval
            case "togethercomputer/m2-bert-80M-8k-retrieval":
                self = .togetherM2Bert80M8KRetrieval
            case "togethercomputer/m2-bert-80M-32k-retrieval":
                self = .togetherM2Bert80M32KRetrieval
            case "WhereIsAI/UAE-Large-V1":
                self = .whereIsAIUAELargeV1
            case "BAAI/bge-large-en-v1.5":
                self = .baaiLargeENV15
            case "BAAI/bge-base-en-v1.5":
                self = .baaiBaseENV15
            case "sentence-transformers/msmarco-bert-base-dot-v5":
                self = .sentenceBERT
            case "bert-base-uncased":
                self = .googleBERTBaseUncased
            default:
                return nil
            }
        }
    }
}

extension TogetherAI.Model {
    public enum Completion: String, TogetherAI._ModelType, CaseIterable {
        
        case llama2_70B = "meta-llama/Llama-2-70b-hf"
        case mistral7b = "mistralai/Mistral-7B-v0.1"
        case mixtral8x7b = "mistralai/Mixtral-8x7B-v0.1"
        
        public var name: String {
            switch self {
            case .llama2_70B:
                return "LLaMA-2 (70B)"
            case .mistral7b:
                return "Mistral (7B)"
            case .mixtral8x7b:
                return "Mixtral-8x7B (46.7B)"
            }
        }
        
        public var contextSize: Int {
            switch self {
            case .llama2_70B:
                return 4096
            case .mistral7b:
                return 8192
            case .mixtral8x7b:
                return 32768
            }
        }
        
        public init?(rawValue: String) {
            switch rawValue {
            case "meta-llama/Llama-2-70b-hf":
                self = .llama2_70B
            case "mistralai/Mistral-7B-v0.1":
                self = .mistral7b
            case "mistralai/Mixtral-8x7B-v0.1":
                self = .mixtral8x7b
            default:
                return nil
            }
        }
    }
}

// MARK: - Conformances

extension TogetherAI.Model: Codable {
    public init(from decoder: Decoder) throws {
        self = try Self(rawValue: try String(from: decoder)).unwrap()
    }
    
    public func encode(to encoder: Encoder) throws {
        try rawValue.encode(to: encoder)
    }
}

extension TogetherAI.Model: ModelIdentifierRepresentable {
    private enum _DecodingError: Error {
        case invalidModelProvider
    }
    
    public init(from model: ModelIdentifier) throws {
        guard model.provider == .openAI else {
            throw _DecodingError.invalidModelProvider
        }
        
        self = try Self(rawValue: model.name).unwrap()
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: .togetherAI,
            name: rawValue,
            revision: nil
        )
    }
}

extension TogetherAI.Model: RawRepresentable {
    public var rawValue: String {
        switch self {
        case .completion(let model):
            return model.rawValue
        case .embedding(let model):
            return model.rawValue
        case .unknown(let rawValue):
            return rawValue
        }
    }
    
    public init?(rawValue: String) {
        if let model = Completion(rawValue: rawValue) {
            self = .completion(model)
        } else if let model = Embedding(rawValue: rawValue) {
            self = .embedding(model)
        } else {
            self = .unknown(rawValue)
        }
    }
}
