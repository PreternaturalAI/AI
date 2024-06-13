//
// Copyright (c) Vatsal Manot
//

import CoreMI
import LargeLanguageModels
import Merge
import NetworkKit

extension Ollama {
    public struct Model: Codable, Hashable, Identifiable, Named, Sendable {
        public typealias ID = _TypeAssociatedID<Self, String>
        
        public let name: String
        public let digest: String
        public let size: Int
        public let modifiedAt: Date
        
        public var id: ID {
            ID(rawValue: name)
        }
        
        public init(
            name: String,
            digest: String,
            size: Int,
            modifiedAt: Date
        ) {
            self.name = name
            self.digest = digest
            self.size = size
            self.modifiedAt = modifiedAt
        }
    }
}

// MARK: - Conformances

extension Ollama.Model: CustomStringConvertible {
    public var description: String {
        name
    }
}

extension Ollama.Model: ModelIdentifierConvertible {
    public func __conversion() throws -> ModelIdentifier {
        ModelIdentifier(
            provider: ._Ollama,
            name: self.name,
            revision: nil
        )
    }
}
