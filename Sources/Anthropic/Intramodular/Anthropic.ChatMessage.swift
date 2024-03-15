//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Swallow

extension Anthropic {
    public struct ChatMessage: Codable, Hashable, Sendable {
        public enum Role: String, Codable, Sendable {
            case assistant
            case user
        }
        
        public var role: Role
        public var content: String
        
        public init(role: Role, content: String) {
            self.role = role
            self.content = content
        }
    }
}

extension Anthropic.ChatMessage {
    public init(
        role: Role,
        content: [Anthropic.API.ResponseBodies.CreateMessage.Content]
    ) throws {
        assert(content.allSatisfy({ $0.type == .text }))
        
        self.role = role
        self.content = content.map({ $0.text }).joined()
    }
    
    public init(
        from message: AbstractLLM.ChatMessage
    ) throws {
        self.init(
            role: try .init(from: message.role),
            content: try message.content._stripToText()
        )
    }
    
    public func __conversion() throws -> AbstractLLM.ChatMessage {
        AbstractLLM.ChatMessage(
            id: nil,
            role: try AbstractLLM.ChatRole(from: role),
            content: content
        )
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatRole {
    public init(
        from role: Anthropic.ChatMessage.Role
    ) throws {
        switch role {
            case .user:
                self = .user
            case .assistant:
                self = .assistant
        }
    }
}

extension Anthropic.ChatMessage.Role {
    public init(
        from role: AbstractLLM.ChatRole
    ) throws {
        switch role {
            case .system:
                throw Never.Reason.unsupported
            case .user:
                self = .user
            case .assistant:
                self = .assistant
            case .other:
                throw Never.Reason.unsupported
        }
    }
}
