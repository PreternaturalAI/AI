//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Swallow

extension OpenAI {
    public struct Message: Codable, Hashable, Identifiable, Sendable {
        private enum CodingKeys: String, CodingKey {
            case id
            case object
            case createdAt
            case threadID = "threadId"
            case role
            case content
            case assistantID = "assistantId"
            case runID = "runId"
            case fileIdentifiers = "fileIds"
            case metadata
        }
        
        public let id: String
        public let object: OpenAI.ObjectType
        public let createdAt: Int
        public let threadID: String
        public let role: OpenAI.ChatRole
        public let content: [OpenAI.Message.Content]
        public let assistantID: String?
        public let runID: String?
        public let fileIdentifiers: [String]?
        public let metadata: [String: String]?
    }
}

// MARK: - Conformances

extension OpenAI.Message: CustomDebugStringConvertible {
    public var debugDescription: String {
        content.map({ $0.debugDescription }).joined()
    }
}

// MARK: - Auxiliary

extension OpenAI.ChatMessage {
    public init(
        from message: OpenAI.Message
    ) throws {
        self.init(
            id: message.id,
            role: message.role,
            body: try .content(message.content.map {
                try OpenAI.ChatMessageBody._Content(from: $0)
            })
        )
    }
}

extension OpenAI.ChatMessageBody._Content {
    public init(from content: OpenAI.Message.Content) throws {
        enum InitializationError: Swift.Error {
            case unsupportedMessageContent
        }
        
        switch content {
            case .text(let text):
                guard text.text.annotations.isEmpty else {
                    throw InitializationError.unsupportedMessageContent
                }
                
                self = .text(text.text.value)
            case .imageFile:
                throw InitializationError.unsupportedMessageContent
        }
    }
}
