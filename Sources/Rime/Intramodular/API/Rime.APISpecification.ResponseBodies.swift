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
    }
}
