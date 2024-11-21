//
//  Rime.APISpecification.ResponseBodies.swift
//  AI
//
//  Created by Jared Davidson on 11/21/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension Rime.APISpecification {
    enum ResponseBodies {
        public struct Voices: Codable {
            public let voices: [Rime.Voice]
            
            public init(voices: [Rime.Voice]) {
                self.voices = voices
            }
            
            public init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                self.voices = try container.decode([Rime.Voice].self)
            }
            
            public func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()
                try container.encode(voices)
            }
        }
        
        public struct TextToSpeechOutput: Codable {
            public let audioContent: Data
            
            public init(audioContent: Data) {
                self.audioContent = audioContent
            }
            
            enum CodingKeys: String, CodingKey {
                case audioContent
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                let base64String = try container.decode(String.self, forKey: .audioContent)
                
                guard let audioData = Data(base64Encoded: base64String) else {
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: [CodingKeys.audioContent],
                            debugDescription: "Invalid base64 encoded string"
                        )
                    )
                }
                
                self.audioContent = audioData
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                
                let base64String = audioContent.base64EncodedString()
                try container.encode(base64String, forKey: .audioContent)
            }
        }
    }
}
