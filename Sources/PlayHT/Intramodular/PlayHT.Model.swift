//
// Copyright (c) Preternatural AI, Inc.
//

import CoreMI
import CorePersistence
import Foundation
import Swift

extension PlayHT {
    public enum Model: String, Codable, Sendable {
        
        case playHT2 = "PlayHT2.0"
        
        case playHT1 = "PlayHT1.0"
        
        case playHT2Turbo = "PlayHT2.0-turbo"
    }
}

// MARK: - Conformances

extension PlayHT.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension PlayHT.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._PlayHT, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._PlayHT,
            name: rawValue,
            revision: nil
        )
    }
}
