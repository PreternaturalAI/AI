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
            
            // Add custom decoding if the response structure is different
            public init(from decoder: Decoder) throws {
                // If the response is an array directly
                if let container = try? decoder.singleValueContainer(),
                   let voices = try? container.decode([PlayHT.Voice].self) {
                    self.voices = voices
                } else {
                    // Try decoding as an object with a voices key
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    self.voices = try container.decode([PlayHT.Voice].self, forKey: .voices)
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case voices
            }
        }
        
        public struct TextToSpeechOutput: Codable {
            public let id: String
            public let status: String
            public let created: String
            public let input: TextToSpeechInput
            public let output: String?
            public let links: [Link]
            
            private enum CodingKeys: String, CodingKey {
                case id, status, created, input, output
                case links = "_links"
            }
            
            public struct TextToSpeechInput: Codable {
                public let speed: Double
                public let outputFormat: String
                public let sampleRate: Int
                public let seed: Int?
                public let temperature: Double?
                public let text: String
                public let voice: String
                public let quality: String
                
                private enum CodingKeys: String, CodingKey {
                    case speed
                    case outputFormat = "output_format"
                    case sampleRate = "sample_rate"
                    case seed, temperature, text, voice, quality
                }
            }
            
            public struct Link: Codable {
                public let rel: String
                public let method: String
                public let contentType: String
                public let description: String
                public let href: String
            }
        }
        
        public struct ClonedVoiceOutput: Codable {
            public let id: String
            public let name: String
            public let status: String
        }
    }
}
