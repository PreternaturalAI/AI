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
        
    }
}

extension Rime.APISpecification.RequestBodies {
    struct TextToSpeechInput: Codable {
        fileprivate enum CodingKeys: String, CodingKey {
            case speaker
            case text
            case modelID = "modelId"
        }
        
        let speaker: String
        let text: String
        let modelID: String
        
        init(
            speaker: String,
            text: String,
            modelID: String
        ) {
            self.speaker = speaker
            self.text = text
            self.modelID = modelID
        }
    }
}
