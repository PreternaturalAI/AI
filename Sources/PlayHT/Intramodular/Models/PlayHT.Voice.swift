//
//  PlayHT.Voice.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import Foundation
import ElevenLabs

extension PlayHT {
    public struct Voice: Codable, Hashable, Identifiable {
        public typealias ID = _TypeAssociatedID<Self, String>
        
        public let id: ID
        public let name: String
        public let language: String
        public let voiceEngine: Model
        public let isCloned: Bool
        public let gender: String?
        public let accent: String?
        public let age: String?
        public let style: String?
        public let useCase: String?
        
        private enum CodingKeys: String, CodingKey {
            case id, name, language, gender, accent, age, style
            case voiceEngine = "voice_engine"
            case isCloned = "cloned"
            case useCase = "use_case"
        }
    }
    
    public enum Quality: String, Codable {
        case draft = "draft"
        case low = "low"
        case medium = "medium"
        case high = "high"
        case premium = "premium"
    }
    
    public enum OutputFormat: String, Codable {
        case mp3 = "mp3"
        case wav = "wav"
        case ogg = "ogg"
        case mulaw = "mulaw"
        case flac = "flac"
    }
}

#warning("This is only a temporary fix. Remove these & replace with Abstract (@jared)")

extension PlayHT.Voice {
    public func toElevenLabsVoice() -> ElevenLabs.Voice {
        ElevenLabs.Voice(
            voiceID: id.rawValue,
            name: name,
            description: style,
            isOwner: isCloned
        )
    }
}

extension PlayHT.VoiceSettings {
    public static func fromElevenLabs(_ settings: ElevenLabs.VoiceSettings) -> Self {
        PlayHT.VoiceSettings(
            speed: 1.0,
            temperature: settings.stability,
            voiceGuidance: settings.similarityBoost * 6.0,
            styleGuidance: settings.styleExaggeration * 30.0,
            textGuidance: 1.0 + settings.similarityBoost
        )
    }
}
