//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

extension ElevenLabs {
    public struct APISpecification {
        public var host: URL {
            URL(string: "https://api.elevenlabs.io")!
        }
    }
}

extension ElevenLabs.APISpecification {
    public enum RequestBodies {
        public struct SpeechRequest: Codable {
            public enum CodingKeys: String, CodingKey {
                case text
                case voiceSettings
                case model
            }
            
            public let text: String
            public let voiceSettings: [String: JSON]
            public let model: String?
            
            public init(
                text: String,
                voiceSettings: [String: JSON],
                model: String?
            ) {
                self.text = text
                self.voiceSettings = voiceSettings
                self.model = model
            }
        }
    }
}

extension ElevenLabs.APISpecification {
    public enum ResponseBodies {
        public struct Voices: Codable, Hashable, Sendable {
            public let voices: [ElevenLabs.Voice]
            
            public init(voices: [ElevenLabs.Voice]) {
                self.voices = voices
            }
        }
    }
}

extension ElevenLabs {
    public struct Voice: Codable, Hashable, Identifiable, Sendable {
        public typealias ID = _TypeAssociatedID<Self, String>

        public enum CodingKeys: String, CodingKey {
            case voiceID = "voiceId"
            case name
        }
                
        public let voiceID: String
        public let name: String
        
        public var id: ID {
            ID(rawValue: voiceID)
        }
        
        public init(voiceID: String, name: String) {
            self.voiceID = voiceID
            self.name = name
        }
    }
}
