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
            public let model: ElevenLabs.Model
            
            public init(
                text: String,
                voiceSettings: [String: JSON],
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
    
    public enum Model: String, Codable, Sendable {
        // Information about each model here: https://help.elevenlabs.io/hc/en-us/articles/17883183930129-What-models-do-you-offer-and-what-is-the-difference-between-them
        // Using cutting-edge technology, this is a highly optimized model for real-time applications that require very low latency, but it still retains the fantastic quality offered in our other models. Even if optimized for real-time and more conversational applications, we still recommend testing it out for other applications as it is very versatile and stable.
        case TurboV2 = "eleven_turbo_v2"
        /// This model is a powerhouse, excelling in stability, language diversity, and accuracy in replicating accents and voices. Its speed and agility are remarkable considering its size. Multilingual v2 supports a 28 languages.
        case MultilingualV2 = "eleven_multilingual_v2"
        /// This model was created specifically for English and is the smallest and fastest model we offer. As our oldest model, it has undergone extensive optimization to ensure reliable performance but it is also the most limited and generally the least accurate.
        case EnglishV1 = "eleven_monolingual_v1"
        /// Taking a step towards global access and usage, we introduced Multilingual v1 as our second offering. Has been an experimental model ever since release. To this day, it still remains in the experimental phase.
        case MultilingualV1 = "eleven_multilingual_v1"
    }
}
