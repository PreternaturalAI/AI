//
// Copyright (c) Vatsal Manot
//

import CoreGML
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

extension Ollama.Model: _GMLModelIdentifierConvertible {
    public func __conversion() throws -> _GMLModelIdentifier {
        _GMLModelIdentifier(
            provider: ._Ollama,
            name: self.name,
            revision: nil
        )
    }
}
