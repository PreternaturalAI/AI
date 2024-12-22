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
            
            public init(from decoder: Decoder) throws {
                if let container: SingleValueDecodingContainer = try? decoder.singleValueContainer(),
                   let voices: [PlayHT.Voice] = try? container.decode([PlayHT.Voice].self) {
                    self.voices = voices
                } else {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.voices = try container.decode([PlayHT.Voice].self, forKey: .voices)
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case voices
            }
        }
        
        public struct ClonedVoiceOutput: Codable {
            public let id: String
            public let name: String
            public let status: String
        }
        
        public struct TextToSpeechResponse: Codable {
            public let description: String
            public let method: String
            public let href: String
            public let contentType: String
            public let rel: String
        }
    }
}
