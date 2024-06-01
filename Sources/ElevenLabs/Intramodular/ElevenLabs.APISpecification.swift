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
    enum RequestBodies {
        public struct SpeechRequest: Codable {
            public enum CodingKeys: String, CodingKey {
                case text
                case voiceSettings
                case model
            }
            
            let text: String
            let voiceSettings: ElevenLabs.VoiceSettings
            let model: ElevenLabs.Model
            
            init(
                text: String,
                voiceSettings: ElevenLabs.VoiceSettings,
                model: ElevenLabs.Model
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
