//
//  ElevenLabs.DubbingOptions.swift
//  AI
//
//  Created by Jared Davidson on 1/7/25.
//

extension ElevenLabs.Client {
    public struct DubbingOptions {
        public var watermark: Bool?
        public var startTime: Int?
        public var endTime: Int?
        public var highestResolution: Bool?
        public var dropBackgroundAudio: Bool?
        public var useProfanityFilter: Bool?
        
        public init(
            watermark: Bool? = nil,
            startTime: Int? = nil,
            endTime: Int? = nil,
            highestResolution: Bool? = nil,
            dropBackgroundAudio: Bool? = nil,
            useProfanityFilter: Bool? = nil
        ) {
            self.watermark = watermark
            self.startTime = startTime
            self.endTime = endTime
            self.highestResolution = highestResolution
            self.dropBackgroundAudio = dropBackgroundAudio
            self.useProfanityFilter = useProfanityFilter
        }
    }
}
