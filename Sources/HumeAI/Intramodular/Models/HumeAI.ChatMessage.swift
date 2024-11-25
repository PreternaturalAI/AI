//
//  HumeAI.ChatMessage.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
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
