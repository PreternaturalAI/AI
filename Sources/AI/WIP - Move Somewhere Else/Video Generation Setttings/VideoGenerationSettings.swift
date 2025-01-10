//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

public struct VideoGenerationSettings: Codable, Hashable, Equatable {
    /// Duration of the generated video in seconds (1-60)
    public var duration: Double {
        didSet {
            duration = max(1, min(60, duration))
        }
    }
    
    public var resolution: Resolution
    public var frameRate: FrameRate
    public var quality: Quality
    public var styleStrength: StyleStrength
    public var motion: MotionSettings
    public var negativePrompt: String
    
    public var fps: Int { frameRate.fps }
    public var numInferenceSteps: Int { quality.inferenceSteps }
    public var guidanceScale: Double { styleStrength.guidanceScale }
    
    public init(
        duration: Double = 10.0,
        resolution: Resolution = .sd512x512,
        frameRate: FrameRate = .fps24,
        quality: Quality = .balanced,
        styleStrength: StyleStrength = .balanced,
        motion: MotionSettings = MotionSettings(),
        negativePrompt: String = ""
    ) {
        self.duration = max(1, min(60, duration))
        self.resolution = resolution
        self.frameRate = frameRate
        self.quality = quality
        self.styleStrength = styleStrength
        self.motion = motion
        self.negativePrompt = negativePrompt
    }
}
