//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swift

extension ElevenLabs {
    public struct Voice: Codable, Hashable, Identifiable, Sendable {
        public typealias ID = _TypeAssociatedID<Self, String>

        public enum CodingKeys: String, CodingKey {
            case voiceID = "voiceId"
            case name
        }
                
        public let voiceID: String
        public let name: String
        
        public var id: ID {
            ID(rawValue: voiceID)
        }
        
        public init(voiceID: String, name: String) {
            self.voiceID = voiceID
            self.name = name
        }
    }
}
