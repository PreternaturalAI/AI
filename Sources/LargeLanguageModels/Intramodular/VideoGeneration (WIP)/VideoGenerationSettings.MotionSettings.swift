//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension VideoGenerationSettings {
    public struct MotionSettings: Codable, Hashable {
        public var stabilize: Bool
        public var motionBucketId: Int // 0-127
        public var conditioningAugmentation: Double // 0.01-0.1
        
        public init(
            stabilize: Bool = true,
            motionBucketId: Int = 127,
            conditioningAugmentation: Double = 0.02
        ) {
            self.stabilize = stabilize
            self.motionBucketId = max(0, min(127, motionBucketId))
            self.conditioningAugmentation = max(0.01, min(0.1, conditioningAugmentation))
        }
    }
}
