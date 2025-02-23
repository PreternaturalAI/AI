//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift
import LargeLanguageModels

extension ElevenLabs {
    public struct Voice: Hashable, Identifiable, Sendable {
        public typealias ID = _TypeAssociatedID<Self, String>
        
        public let voiceID: String
        public let name: String
        public let description: String?
        public let isOwner: Bool?
        
        public var id: ID {
            ID(rawValue: voiceID)
        }
        
        public init(
            voiceID: String,
            name: String,
            description: String?,
            isOwner: Bool?
        ) {
            self.voiceID = voiceID
            self.name = name
            self.description = description
            self.isOwner = isOwner
        }
    }
}

// MARK: - Conformances

extension ElevenLabs.Voice: Codable {
    enum CodingKeys: String, CodingKey {
        case voiceID = "voiceId"
        case name
        case description
        case isOwner
    }
}

extension ElevenLabs.Voice: AbstractVoiceConvertible {
    public func __conversion() throws -> AbstractVoice {
        return AbstractVoice(
            voiceID: self.voiceID,
            name: self.name,
            description: self.description
        )
    }
}

extension ElevenLabs.Voice: AbstractVoiceInitiable {
    public init(voice: AbstractVoice) throws {
        self.init(
            voiceID: voice.voiceID,
            name: voice.name,
            description: voice.description,
            isOwner: nil
        )
    }
}
