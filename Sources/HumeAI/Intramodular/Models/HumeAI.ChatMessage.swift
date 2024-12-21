//
// Copyright (c) Preternatural AI, Inc.
//

extension HumeAI {
    public struct ChatMessage {
        public let role: String
        public let content: String
        
        public init(role: String, content: String) {
            self.role = role
            self.content = content
        }
    }
}
