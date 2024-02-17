//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swift

public protocol TextToSpeechRequest: _MIRequest {
    
}

public struct NaiveTextToSpeechRequest: Codable, Hashable, Sendable, TextToSpeechRequest {
    public let text: String
}

extension NaiveTextToSpeechRequest {
    public struct Result {
        public let data: Data
    }
}
