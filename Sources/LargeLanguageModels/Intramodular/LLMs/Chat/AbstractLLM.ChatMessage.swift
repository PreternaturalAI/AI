//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Diagnostics
import Foundation
import Swallow
import SwiftUIX

/// A type that can be constructed from an `AbstractLLM.ChatMessage`.
public protocol __AbstractLLM_ChatMessageInitiable {
    init(from message: AbstractLLM.ChatMessage) throws
}

/// A type whose instances can be converted to a `AbstractLLM.ChatMessage`.
public protocol __AbstractLLM_ChatMessageConvertible {
    func __conversion() throws -> AbstractLLM.ChatMessage
}

extension AbstractLLM {
    public typealias ChatMessageInitiable = __AbstractLLM_ChatMessageInitiable
    public typealias ChatMessageConvertible = __AbstractLLM_ChatMessageConvertible
}

extension AbstractLLM {
    /// A type that represents a generic chat-message suitable for use with a language-model.
    ///
    /// See `OpenAI.ChatMessage+LargeLanguageModels.swift` in the `OpenAI` module for an example for how to convert an `AbstractLLM.ChatMessage` to a provider-specific message type.
    public struct ChatMessage: Codable, Hashable, Identifiable, Sendable {
        public var id: AnyPersistentIdentifier?
        public var role: ChatRole
        public var content: PromptLiteral

        public init(
            id: AnyPersistentIdentifier? = nil,
            role: ChatRole,
            content: PromptLiteral
        ) {
            #try(.optimistic) {
                if let functionCallOrInvocation = try content._degenerate()._getFunctionCallOrInvocation() {
                    if functionCallOrInvocation is ChatFunctionCall {
                        assert(role == .assistant)
                    } else if functionCallOrInvocation is AbstractLLM.ResultOfFunctionCall {
                        assert(role == .other(.function))
                    }
                }
            }
            
            self.id = id
            self.role = role
            self.content = content
        }
        
        public init(
            role: ChatRole,
            body: PromptLiteral
        ) {
            self.id = nil
            self.role = role
            self.content = body
        }
    }
}

// MARK: - Extensions

extension AbstractLLM.ChatMessage {
    public mutating func _appendUnsafely(
        other message: Self
    ) {
        assert(role == message.role)
        
        self = Self(
            role: role,
            content: PromptLiteral.concatenate(separator: nil, [content, message.content])
        )
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatMessage: AbstractLLM.ChatMessageConvertible {
    public func __conversion() throws -> AbstractLLM.ChatMessage {
        self
    }
}

extension AbstractLLM.ChatMessage: CustomStringConvertible, CustomDebugStringConvertible {
    public var debugDescription: String {
        "[\(role)]: \(content.delimited(by: .quotationMark))"
    }
    
    public var description: String {
        "\(content)"
    }
}
