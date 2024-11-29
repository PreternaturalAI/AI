//
//  ElevenLabs.APISpecification.ResponseBodies.swift
//  AI
//
//  Created by Jared Davidson on 11/18/24.
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
