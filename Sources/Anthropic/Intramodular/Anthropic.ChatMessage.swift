//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Foundation
import LargeLanguageModels
import Swallow

extension Anthropic {
    public struct ChatMessage: Codable, Hashable, Sendable {
        public enum Role: String, Codable, Sendable {
            case assistant
            case user
        }
        
        public var id: String?
        public var role: Role
        public var content: Content
        
        public init(
            id: String? = nil,
            role: Role,
            content: Content
        ) throws {
            self.id = id
            self.role = role
            self.content = content
        }
        
        public init(
            id: String? = nil,
            role: Role,
            content: String
        ) throws {
            try self.init(id: id, role: role, content: .text(content))
        }
        
        public init(
            id: String? = nil,
            role: Role,
            content: [Content.ContentObject]
        ) throws {
            try self.init(id: id, role: role, content: .list(content))
        }
    }
}

// MARK: - Conformances

extension Anthropic.ChatMessage: AbstractLLM.ChatMessageConvertible {
    public func __conversion() throws -> AbstractLLM.ChatMessage {
        .init(
            id: AnyPersistentIdentifier(rawValue: id ?? UUID().uuidString),
            role: try AbstractLLM.ChatRole(from: role),
            content: try PromptLiteral(from: self)
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
