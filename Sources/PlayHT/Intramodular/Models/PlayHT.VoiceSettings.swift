//
// Copyright (c) Preternatural AI, Inc.
//

extension PlayHT {
    public struct VoiceSettings: Codable, Hashable {
        public var speed: Double
        public var temperature: Double
        public var voiceGuidance: Double
        public var styleGuidance: Double
        public var textGuidance: Double
        
        public init(
            speed: Double = 1.0,
            temperature: Double = 1.0,
            voiceGuidance: Double = 3.0,
            styleGuidance: Double = 15.0,
            textGuidance: Double = 1.5
        ) {
            self.speed = max(0.1, min(5.0, speed))
            self.temperature = max(0, min(2.0, temperature))
            self.voiceGuidance = max(1, min(6.0, voiceGuidance))
            self.styleGuidance = max(1, min(30.0, styleGuidance))
            self.textGuidance = max(1, min(2.0, textGuidance))
        }
    }
}
