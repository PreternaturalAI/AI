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
        
        public struct DubbingResponse: Codable {
            public let dubbingId: String
            public let expectedDurationSec: Double
        }
        
        public struct DubbingStatus: Codable {
            public enum State: String, Codable {
                case processing
                case completed
                case failed
            }
            
            public let state: State
            public let failure_reason: String?
            public let progress: Double?
        }
        
        public struct DubbingProgress: Codable {
            public let status: DubbingStatus
            public let expectedDuration: TimeInterval
            public let dubbingId: String
        }
    }
}
