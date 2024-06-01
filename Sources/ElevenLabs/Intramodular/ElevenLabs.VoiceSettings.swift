//
// Copyright (c) Vatsal Manot
//

import Foundation

extension ElevenLabs {
    public final class VoiceSettings: Codable, Sendable {
        
        public enum Setting: String, Codable, Sendable {
            case stability
            case similarityBoost = "similarity_boost"
            case styleExaggeration = "style"
            case speakerBoost = "use_speaker_boost"
        }
        
        /// Increasing stability will make the voice more consistent between re-generations, but it can also make it sounds a bit monotone. On longer text fragments it is recommended to lower this value.
        /// This is a double between 0 (more variable) and 1 (more stable).
        public let stability: Double
        
        /// Increasing the Similarity Boost setting enhances the overall voice clarity and targets speaker similarity. However, very high values can cause artifacts, so it is recommended to adjust this setting to find the optimal value.
        /// This is a double between 0 (Low) and 1 (High).
        public let similarityBoost: Double
        
        /// High values are recommended if the style of the speech should be exaggerated compared to the selected voice. Higher values can lead to more instability in the generated speech. Setting this to 0 will greatly increase generation speed and is the default setting.
        public let styleExaggeration: Double
        
        /// Boost the similarity of the synthesized speech and the voice at the cost of some generation speed.
        public let speakerBoost: Bool
        
        public init(stability: Double,
                    similarityBoost: Double,
                    styleExaggeration: Double,
                    speakerBoost: Bool) {
            self.stability = max(0, min(1, stability))
            self.similarityBoost = max(0, min(1, similarityBoost))
            self.styleExaggeration = max(0, min(1, styleExaggeration))
            self.speakerBoost = speakerBoost
        }
        
        public init(stability: Double? = nil,
                    similarityBoost: Double? = nil,
                    styleExaggeration: Double? = nil,
                    speakerBoost: Bool? = nil) {
            self.stability = stability.map { max(0, min(1, $0)) } ?? 0.5
            self.similarityBoost = similarityBoost.map { max(0, min(1, $0)) } ?? 0.75
            self.styleExaggeration = styleExaggeration.map { max(0, min(1, $0)) } ?? 0
            self.speakerBoost = speakerBoost ?? true
        }
        
        public convenience init(stability: Double) {
            self.init(
                stability: stability,
                similarityBoost: 0.75,
                styleExaggeration: 0,
                speakerBoost: true
            )
        }
        
        public convenience init(similarityBoost: Double) {
            self.init(
                stability: 0.5,
                similarityBoost: similarityBoost,
                styleExaggeration: 0,
                speakerBoost: true
            )
        }
        
        public convenience init(styleExaggeration: Double) {
            self.init(
                stability: 0.5,
                similarityBoost: 0.75,
                styleExaggeration: styleExaggeration,
                speakerBoost: true
            )
        }
        
        public convenience init(speakerBoost: Bool) {
            self.init(
                stability: 0.5,
                similarityBoost: 0.75,
                styleExaggeration: 0,
                speakerBoost: speakerBoost
            )
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(stability, forKey: .stability)
            try container.encode(similarityBoost, forKey: .similarityBoost)
            try container.encode(styleExaggeration, forKey: .styleExaggeration)
            try container.encode(speakerBoost, forKey: .speakerBoost)
        }
    }
}

