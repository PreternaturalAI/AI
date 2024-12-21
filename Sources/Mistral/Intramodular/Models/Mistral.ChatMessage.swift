//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension Mistral {
    public struct ChatMessage: Codable, Hashable, Sendable {
        public enum Role: String, Codable, Hashable, Sendable {
            case system
            case user
            case assistant
        }
        
        public var role: Role
        public var content: String
        
        public init(role: Role, content: String) {
            self.role = role
            self.content = content
        }
    }
}
