//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension VideoGenerationSettings {
    public enum FrameRate: Int, Codable, CaseIterable {
        case fps8 = 8
        case fps16 = 16
        case fps24 = 24
        case fps30 = 30
        
        public var fps: Int { rawValue }
    }
}
