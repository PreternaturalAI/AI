//
//  Rime.APISpecification.RequestBodies.swift
//  AI
//
//  Created by Jared Davidson on 11/21/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension Rime.APISpecification {
    enum RequestBodies {
        public struct TextToSpeechInput: Codable {

            public let speaker: String
            public let text: String
            public let modelId: String
            
            public init(
                speaker: String,
                text: String,
                modelId: String
            ) {
                self.speaker = speaker
                self.text = text
                self.modelId = modelId
            }
        }
    }
}
