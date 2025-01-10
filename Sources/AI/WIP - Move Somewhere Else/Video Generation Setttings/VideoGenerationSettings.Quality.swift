//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension VideoGenerationSettings {
    public enum Quality: String, Codable, CaseIterable {
        case draft = "draft"      // 20 steps
        case fast = "fast"        // 30 steps
        case balanced = "balanced" // 35 steps
        case quality = "quality"  // 40 steps
        case max = "max"         // 50 steps
        
        public var inferenceSteps: Int {
            switch self {
                case .draft: return 20
                case .fast: return 30
                case .balanced: return 35
                case .quality: return 40
                case .max: return 50
            }
        }
        
        public var qualityValue: Double {
            Double(inferenceSteps - 20) / 30
        }
    }
}
