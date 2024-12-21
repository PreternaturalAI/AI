//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension ElevenLabs.APISpecification {
    public enum ResponseBodies {
        public struct Voices: Codable {
            public let voices: [ElevenLabs.Voice]
        }
        
        public struct VoiceID: Codable {
            public let voiceId: String
        }
    }
}
