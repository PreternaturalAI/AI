//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation
import Merge
import Swift

public protocol TTSRequest: CoreMI.Request {
    
}

public struct NaiveTTSRequest: Codable, Hashable, Sendable, TTSRequest {
    public let text: String
}

extension NaiveTTSRequest {
    public struct Result {
        public let data: Data
    }
}
