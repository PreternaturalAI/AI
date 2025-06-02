//
//  ElevenLabs.DubbingResult.swift
//  AI
//
//  Created by Jared Davidson on 1/7/25.
//

import Foundation

extension ElevenLabs.Client {
    public struct DubbingResult {
        public let data: Data
        public let dubbingId: String
        public let totalDuration: TimeInterval
    }
}
