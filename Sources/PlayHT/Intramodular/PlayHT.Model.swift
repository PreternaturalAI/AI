//
//  PlayHT.Model.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import CoreMI
import CorePersistence
import Foundation
import Swift

extension PlayHT {
    public enum Model: String, Codable, Sendable {
        /// Latest speech model optimized for realtime use. Features include:
        /// - Multilingual support (36 languages)
        /// - Reduced hallucinations
        /// - <200ms streaming latency
        /// - 48kHz sampling
        /// - 20k character limit per stream
        case play3Mini = "Play3.0-mini"
        
        case playHT2 = "PlayHT2.0"
        case playHT1 = "PlayHT1.0"
        
        /// Legacy voice model with basic TTS capabilities
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
