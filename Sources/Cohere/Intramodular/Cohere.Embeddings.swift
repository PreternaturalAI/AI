//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension Cohere {
    public struct Embeddings: Codable, Hashable, Sendable {
        public let responseType: String?
        public let id: String
        public let embeddings: [[Float]]
        public let texts: [String]
        public let meta: Meta?
    }
}

extension Cohere.Embeddings {
    public struct Meta: Codable, Hashable, Sendable {
        public let apiVersion: APIVersion
        public let billedUnits: BilledUnits?
        public let tokens: Tokens?
        public let warnings: [String]?
    }
    
    public struct APIVersion: Codable, Hashable, Sendable {
        public let version: String
        public let isDeprecated: Bool?
        public let isExperimental: Bool?
    }
    
    public struct BilledUnits: Codable, Hashable, Sendable {
        public let inputTokens: Int?
        public let outputTokens: Int?
        public let searchUnits: Int?
        public let classifications: Int?
    }
}

extension Cohere.Embeddings {
    public struct Tokens: Codable, Hashable, Sendable {
        public let inputTokens: Int?
        public let outputTokens: Int?
    }
}
