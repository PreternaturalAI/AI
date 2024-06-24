//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension VoyageAI {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        /// Top of MTEB leaderboard. Instruction-tuned general-purpose embedding model optimized
        /// for clustering, classification, and retrieval. For retrieval, please use input_type parameter to
        /// specify whether the text is a query or document. For classification and clustering,
        /// please use the instructions here. See blog post for details.
        /// https://blog.voyageai.com/2024/05/05/voyage-large-2-instruct-instruction-tuned-and-rank-1-on-mteb/
        case voyageLarge2Instruct = "voyage-large-2-instruct"

        /// Optimized for finance retrieval and RAG. See blog post for details.
        /// https://blog.voyageai.com/2024/06/03/domain-specific-embeddings-finance-edition-voyage-finance-2/
        case voyageFinance2 = "voyage-finance-2"

        /// Optimized for multilingual retrieval and RAG. See blog post for details.
        /// https://blog.voyageai.com/2024/06/10/voyage-multilingual-2-multilingual-embedding-model/
        case voyageMultilingual2 = "voyage-multilingual-2"

        /// Optimized for legal and long-context retrieval and RAG. Also improved performance across
        /// all domains. See blog post for details.
        /// https://blog.voyageai.com/2024/04/15/domain-specific-embeddings-and-retrieval-legal-edition-voyage-law-2/
        case voyageLaw2 = "voyage-law-2"

        /// Optimized for code retrieval (17% better than alternatives). See blog post for details.
        /// https://blog.voyageai.com/2024/01/23/voyage-code-2-elevate-your-code-retrieval/
        case voyageCode2 = "voyage-code-2"

        /// General-purpose embedding model that is optimized for retrieval quality (e.g., better than
        /// OpenAI V3 Large).
        case voyageLarge2 = "voyage-large-2"

        /// General-purpose embedding model optimized for a balance between cost, latency, and
        /// retrieval quality.
        case voyage2 = "voyage-2"

        public var name: String { rawValue }

        public var contextLength: Int {
            switch self {
            case .voyageLarge2Instruct: return 16000
            case .voyageFinance2: return 32000
            case .voyageMultilingual2: return 32000
            case .voyageLaw2: return 16000
            case .voyageCode2: return 16000
            case .voyageLarge2: return 16000
            case .voyage2: return 4000
            }
        }

        public var embeddingDimension: Int {
            switch self {
            case .voyageLarge2Instruct: return 1024
            case .voyageFinance2: return 1024
            case .voyageMultilingual2: return 1024
            case .voyageLaw2: return 1024
            case .voyageCode2: return 1536
            case .voyageLarge2: return 1536
            case .voyage2: return 1024
            }
        }
    }
}

// MARK: - Conformances

extension VoyageAI.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension VoyageAI.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._VoyageAI, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._VoyageAI,
            name: rawValue,
            revision: nil
        )
    }
}
