//
//  VoiceStore.swift
//  Voice
//
//  Created by Jared Davidson on 10/30/24.
//

import SwiftUIZ
import CorePersistence
import ElevenLabs

public struct AbstractVoiceSettings: Codable, Sendable, Initiable, Equatable {
    public init() {
        self.init(stability: 1.0)
    }
    
    
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
    
    public init(stability: Double,
                similarityBoost: Double,
                styleExaggeration: Double,
                speakerBoost: Bool,
                removeBackgroundNoise: Bool) {
        self.stability = max(0, min(1, stability))
        self.similarityBoost = max(0, min(1, similarityBoost))
        self.styleExaggeration = max(0, min(1, styleExaggeration))
        self.speakerBoost = speakerBoost
        self.removeBackgroundNoise = removeBackgroundNoise
    }
    
    public init(stability: Double? = nil,
                similarityBoost: Double? = nil,
                styleExaggeration: Double? = nil,
                speakerBoost: Bool? = nil,
                removeBackgroundNoise: Bool? = nil) {
        self.stability = stability.map { max(0, min(1, $0)) } ?? 0.5
        self.similarityBoost = similarityBoost.map { max(0, min(1, $0)) } ?? 0.75
        self.styleExaggeration = styleExaggeration.map { max(0, min(1, $0)) } ?? 0
        self.speakerBoost = speakerBoost ?? true
        self.removeBackgroundNoise = removeBackgroundNoise ?? false
    }
    
    public init(stability: Double) {
        self.init(
            stability: stability,
            similarityBoost: 0.75,
            styleExaggeration: 0,
            speakerBoost: true,
            removeBackgroundNoise: false
        )
    }
    
    public init(similarityBoost: Double) {
        self.init(
            stability: 0.5,
            similarityBoost: similarityBoost,
            styleExaggeration: 0,
            speakerBoost: true,
            removeBackgroundNoise: false
        )
    }
    
    public init(styleExaggeration: Double) {
        self.init(
            stability: 0.5,
            similarityBoost: 0.75,
            styleExaggeration: styleExaggeration,
            speakerBoost: true,
            removeBackgroundNoise: false
        )
    }
    
    public init(speakerBoost: Bool) {
        self.init(
            stability: 0.5,
            similarityBoost: 0.75,
            styleExaggeration: 0,
            speakerBoost: speakerBoost,
            removeBackgroundNoise: false
        )
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


public protocol AbstractVoiceSettingsInitiable {
    init(settings: AbstractVoiceSettings) throws
}

public protocol AbstractVoiceSettingsConvertible {
    func __conversion() throws -> AbstractVoiceSettings
}

extension ElevenLabs.VoiceSettings: AbstractVoiceSettingsConvertible {
    public func __conversion() throws -> AbstractVoiceSettings {
        return .init(
            stability: stability,
            similarityBoost: similarityBoost,
            styleExaggeration: styleExaggeration,
            speakerBoost: speakerBoost,
            removeBackgroundNoise: removeBackgroundNoise
        )
    }
}

extension ElevenLabs.VoiceSettings: AbstractVoiceSettingsInitiable {
    public init(settings: AbstractVoiceSettings) throws {
        self.init(
            stability: settings.stability,
            similarityBoost: settings.similarityBoost,
            styleExaggeration: settings.styleExaggeration,
            speakerBoost: settings.speakerBoost,
            removeBackgroundNoise: settings.removeBackgroundNoise
        )
    }
}
