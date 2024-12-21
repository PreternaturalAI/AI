//
// Copyright (c) Preternatural AI, Inc.
//

import CoreMI
import CorePersistence
import Foundation
import Swift

extension Rime {
    public enum Model: String, Codable, Sendable {
        case mist = "mist"
        case v1 = "v1"
    }
}

// MARK: - Conformances

extension Rime.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Rime.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._Rime, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() throws -> ModelIdentifier {
        ModelIdentifier(
            provider: ._Rime,
            name: rawValue,
            revision: nil
        )
    }
}
