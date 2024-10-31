//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension ElevenLabs {
    // MARK: - Voice Model
    public struct Voice: Codable, Hashable, Identifiable, Sendable {
        public typealias ID = _TypeAssociatedID<Self, String>
        
        public let voiceID: String
        public let name: String
        public let description: String?
        public let isOwner: Bool
        
        public var id: ID {
            ID(rawValue: voiceID)
        }
        
        enum CodingKeys: String, CodingKey {
            case voiceID = "voiceId"
            case name
            case description
            case isOwner
        }
    }
}
