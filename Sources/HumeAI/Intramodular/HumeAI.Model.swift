//
//  HumeAI.Model.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import CoreMI
import CorePersistence
import Foundation
import Swift

extension HumeAI {
    public enum Model: String, Codable, Sendable {
        case prosody = "prosody"
        case language = "language"
        case burst = "burst"
        case face = "face"
        case speech = "speech"
        case tts = "tts"
    }
}
