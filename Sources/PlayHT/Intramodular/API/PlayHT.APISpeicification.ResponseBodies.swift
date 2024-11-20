//
//  PlayHT.APISpeicification.ResponseBodies.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import Foundation

extension PlayHT.APISpecification {
    public enum ResponseBodies {
        public struct Voices: Codable {
            public let voices: [PlayHT.Voice]
        }
        
        public struct TextToSpeechOutput: Codable {
            public let transcriptionId: String
            public let audioUrl: String?
        }
        
        public struct ClonedVoiceOutput: Codable {
            public let id: String
            public let name: String
            public let status: String
        }
    }
}
