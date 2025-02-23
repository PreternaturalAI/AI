//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension VideoGenerationSettings {
    public enum StyleStrength: String, Codable, CaseIterable {
        case subtle = "subtle"     // 1-5
        case balanced = "balanced" // 5-10
        case strong = "strong"    // 10-15
        case extreme = "extreme"  // 15-20
        
        public var guidanceScale: Double {
            switch self {
                case .subtle: return 3.0
                case .balanced: return 7.5
                case .strong: return 12.5
                case .extreme: return 17.5
            }
        }
        
        public var strengthValue: Double {
            (guidanceScale - 1) / 19
        }
    }
}
