//
// Copyright (c) Vatsal Manot
//

import Swift

extension AbstractLLM.ChatCompletion {
    @frozen
    public struct StopReason: Codable, Hashable, Sendable {
        public enum StopReasonType: Codable, CaseIterable, Hashable, Sendable {
            case endTurn
            case maxTokens
            case stopSequence
        }
        
        public let type: StopReasonType?
        
        public init(type: StopReasonType? = nil) {
            self.type = type
        }
    }
}

extension AbstractLLM.ChatCompletion.StopReason {
    public static var endTurn: Self {
        Self(type: .endTurn)
    }
    
    public static var maxTokens: Self {
        Self(type: .maxTokens)
    }
    
    public static var stopSequence: Self {
        Self(type: .stopSequence)
    }
}
