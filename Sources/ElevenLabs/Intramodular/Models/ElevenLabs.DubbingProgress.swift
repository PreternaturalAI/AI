//
//  ElevenLabs.DubbingProgress.swift
//  AI
//
//  Created by Jared Davidson on 1/7/25.
//

import Foundation

extension ElevenLabs.Client {
    public struct DubbingProgress {
        public let status: ElevenLabs.APISpecification.ResponseBodies.DubbingStatus
        public let expectedDuration: TimeInterval
        public let dubbingId: String
    }
}
