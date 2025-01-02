//
//  PlayHT.Voice.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import Foundation
import Swallow

extension PlayHT {
    public struct Voice: Codable, Hashable, Identifiable {
        public typealias ID = _TypeAssociatedID<Self, String>
        
        public let id: ID
        public let name: String
        public let language: String?
        public let languageCode: String?
        public let voiceEngine: String
        public let isCloned: Bool?
        public let gender: String?
        public let accent: String?
        public let age: String?
        public let style: String?
        public let sample: String?
        public let texture: String?
        public let loudness: String?
        public let tempo: String?

        private enum CodingKeys: String, CodingKey {
            case id, name, language, languageCode, voiceEngine, isCloned
            case gender, accent, age, style, sample, texture, loudness, tempo
        }
        
        public init(
            id: String,
            name: String,
            language: String
        ) {
            self.id = .init(rawValue: id)
            self.name = name
            self.language = language
            self.languageCode = nil
            self.voiceEngine = ""
            self.isCloned = nil
            self.gender = nil
            self.accent = nil
            self.age = nil
            self.style = nil
            self.sample = nil
            self.texture = nil
            self.loudness = nil
            self.tempo = nil
        }

        // Add custom decoding if needed to handle any special cases
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try ID(rawValue: container.decode(String.self, forKey: .id))
            self.name = try container.decode(String.self, forKey: .name)
            self.language = try container.decodeIfPresent(String.self, forKey: .language)
            self.languageCode = try container.decodeIfPresent(String.self, forKey: .languageCode)
            self.voiceEngine = try container.decode(String.self, forKey: .voiceEngine)
            
            self.isCloned = try container.decodeIfPresent(Bool.self, forKey: .isCloned) ?? true
            // isCloned is always false if not created by user. Otherwise doesn't exist so we set to true
            
            self.gender = try container.decodeIfPresent(String.self, forKey: .gender)
            self.accent = try container.decodeIfPresent(String.self, forKey: .accent)
            self.age = try container.decodeIfPresent(String.self, forKey: .age)
            self.style = try container.decodeIfPresent(String.self, forKey: .style)
            self.sample = try container.decodeIfPresent(String.self, forKey: .sample)
            self.texture = try container.decodeIfPresent(String.self, forKey: .texture)
            self.loudness = try container.decodeIfPresent(String.self, forKey: .loudness)
            self.tempo = try container.decodeIfPresent(String.self, forKey: .tempo)
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
