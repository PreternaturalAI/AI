//
// Copyright (c) Vatsal Manot
//

import Foundation

extension ElevenLabs {
    public struct VoiceSettings: Codable, Sendable, Hashable {
        public enum Setting: String, Codable, Sendable {
            case stability
            case similarityBoost = "similarity_boost"
            case styleExaggeration = "style"
            case speakerBoost = "use_speaker_boost"
        }
        
        /// Increasing stability will make the voice more consistent between re-generations, but it can also make it sounds a bit monotone. On longer text fragments it is recommended to lower this value.
        /// This is a double between 0 (more variable) and 1 (more stable).
        public var stability: Double
        
        /// Increasing the Similarity Boost setting enhances the overall voice clarity and targets speaker similarity. However, very high values can cause artifacts, so it is recommended to adjust this setting to find the optimal value.
        /// This is a double between 0 (Low) and 1 (High).
        public var similarityBoost: Double
        
        /// High values are recommended if the style of the speech should be exaggerated compared to the selected voice. Higher values can lead to more instability in the generated speech. Setting this to 0 will greatly increase generation speed and is the default setting.
        public var styleExaggeration: Double
        
        /// Boost the similarity of the synthesized speech and the voice at the cost of some generation speed.
        public var speakerBoost: Bool
        
        public var removeBackgroundNoise: Bool
        
        public init(
            stability: Double? = nil,
            similarityBoost: Double? = nil,
            styleExaggeration: Double? = nil,
            speakerBoost: Bool? = nil,
            removeBackgroundNoise: Bool? = nil
        ) {
            self.stability = stability.map { max(0, min(1, $0)) } ?? 0.5
            self.similarityBoost = similarityBoost.map { max(0, min(1, $0)) } ?? 0.75
            self.styleExaggeration = styleExaggeration.map { max(0, min(1, $0)) } ?? 0
            self.speakerBoost = speakerBoost ?? true
            self.removeBackgroundNoise = removeBackgroundNoise ?? false
        }
                        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(stability, forKey: .stability)
            try container.encode(similarityBoost, forKey: .similarityBoost)
            try container.encode(styleExaggeration, forKey: .styleExaggeration)
            try container.encode(speakerBoost, forKey: .speakerBoost)
            try container.encode(removeBackgroundNoise, forKey: .removeBackgroundNoise)
        }
    }
}

// MARK: - Initializers

extension ElevenLabs.VoiceSettings {
    public init(stability: Double) {
        self.init(
            stability: stability,
            similarityBoost: nil,
            styleExaggeration: nil,
            speakerBoost: nil,
            removeBackgroundNoise: nil
        )
    }

    public init(similarityBoost: Double) {
        self.init(
            stability: nil,
            similarityBoost: similarityBoost,
            styleExaggeration: nil,
            speakerBoost: nil,
            removeBackgroundNoise: nil
        )
    }
    
    public init(styleExaggeration: Double) {
        self.init(
            stability: nil,
            similarityBoost: nil,
            styleExaggeration: styleExaggeration,
            speakerBoost: true,
            removeBackgroundNoise: nil
        )
    }
    
    public init(speakerBoost: Bool) {
        self.init(
            stability: nil,
            similarityBoost: nil,
            styleExaggeration: nil,
            speakerBoost: speakerBoost,
            removeBackgroundNoise: nil
        )
    }
}
