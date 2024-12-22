//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Merge
import NetworkKit

extension Ollama {
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

// MARK: - Conformances

extension Ollama.ChatMessage: AbstractLLM.ChatMessageConvertible {
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
        from role: Ollama.ChatMessage.Role
    ) throws {
        switch role {
            case .system:
                self = .system
            case .user:
                self = .user
            case .assistant:
                self = .assistant
        }
    }
}

extension Ollama.ChatMessage {
    public init(
        from message: AbstractLLM.ChatMessage
    ) throws {
        self.init(
            role: try Ollama.ChatMessage.Role(
                from: message.role
            ),
            content: try message.content._stripToText()
        )
    }
}

extension Ollama.ChatMessage.Role {
    public init(
        from role: AbstractLLM.ChatRole
    ) throws {
        switch role {
            case .system:
                self = .system
            case .user:
                self = .user
            case .assistant:
                self = .assistant
            case .other:
                throw Never.Reason.unsupported
        }
    }
}
