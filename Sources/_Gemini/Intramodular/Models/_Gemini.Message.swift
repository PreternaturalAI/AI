//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension _Gemini {
    public struct Message: Codable {
        public let role: Role
        public let content: String
        
        public init(role: Role, content: String) {
            self.role = role
            self.content = content
        }
        internal func toRequestContent() -> _Gemini.APISpecification.RequestBodies.Content {
            .init(role: role.rawValue, parts: [.text(content)])
        }
    }
    
    public enum Role: String, Codable {
        case user = "user"
        case system = "system"
        case assistant = "assistant"
    }
}
