//
// Copyright (c) Vatsal Manot
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
                    } else if functionCallOrInvocation is AbstractLLM.ChatFunctionInvocation {
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

// MARK: - Initializers

extension AbstractLLM.ChatMessage {
    public init(
        id: AnyPersistentIdentifier? = nil,
        role: AbstractLLM.ChatRole,
        content: String
    ) {
        self.init(
            id: id,
            role: role,
            content: PromptLiteral(stringLiteral: content)
        )
    }
    
    public init(
        id: UUID,
        role: AbstractLLM.ChatRole,
        content: String
    ) {
        self.init(
            id: AnyPersistentIdentifier(erasing: id),
            role: role,
            content: content
        )
    }
}

extension AbstractLLM.ChatMessage {
    public static func system(
        _ content: PromptLiteral
    ) -> Self {
        Self(role: .system, content: content)
    }
    
    public static func system(
        _ content: () throws -> PromptLiteral
    ) rethrows -> Self {
        Self(role: .system, content: try content())
    }
    
    public static func system(
        _ content: String
    ) -> Self {
        Self(role: .system, content: content)
    }
    
    public static func system(
        _ content: () throws -> String
    ) rethrows -> Self {
        Self(role: .system, content: try content())
    }
}

extension AbstractLLM.ChatMessage {
    public static func assistant(
        _ content: PromptLiteral
    ) -> Self {
        Self(role: .assistant, content: content)
    }
    
    public static func assistant(
        _ content: () throws -> PromptLiteral
    ) rethrows -> Self {
        Self(role: .assistant, content: try content())
    }
    
    public static func assistant(
        _ content: String
    ) -> Self {
        Self(role: .assistant, content: content)
    }
    
    public static func assistant(
        _ content: () throws -> String
    ) rethrows -> Self {
        Self(role: .assistant, content: try content())
    }
    
    /// A function call.
    public static func functionCall(
        _ functionCall: AbstractLLM.ChatFunctionCall
    ) -> Self {
        Self(role: .assistant, content: try! PromptLiteral(functionCall: functionCall))
    }
    
    /// The function call of a given function, with its arguments expressed as JSON.
    public static func functionCall(
        of function: AbstractLLM.ChatFunctionDefinition,
        arguments: JSON
    ) -> Self {
        Self(
            role: .assistant,
            content: try! PromptLiteral(
                functionCall: AbstractLLM.ChatFunctionCall(
                    name: function.name,
                    arguments: arguments.prettyPrintedDescription,
                    context: .init()
                )
            )
        )
    }
    
    /// A function invocation is a function call + the result.
    ///
    /// Conceptually, this represents the function call as the LLM would invoke it _including_ the function's result.
    ///
    /// You can construct it manually as part of few-shot prompting to guide the LLM on how to call your function.
    ///
    /// This is **not** the same thing as just a 'function call'. A function call is **only** the function name + the parameters that the LLM generates to invoke it, _without_ the actual result of the function.
    public static func functionInvocation(
        _ functionInvocation: AbstractLLM.ChatFunctionInvocation
    ) -> Self {
        Self(
            role: .other(.function),
            content: try! PromptLiteral(
                functionInvocation: functionInvocation,
                role: .chat(.other(.function))
            )
        )
    }
}

extension AbstractLLM.ChatMessage {
    public static func user(
        _ content: PromptLiteral
    ) -> Self {
        Self(role: .user, content: content)
    }
    
    public static func user(
        _ content: AppKitOrUIKitImage
    ) -> Self {
        Self(role: .user, content: try! PromptLiteral(image: content))
    }
    
    public static func user(
        _ content: () throws -> PromptLiteral
    ) rethrows -> Self {
        Self(role: .user, content: try content())
    }
    
    public static func user(
        _ content: String
    ) -> Self {
        Self(role: .user, content: content)
    }
    
    public static func user(
        _ content: () throws -> String
    ) rethrows -> Self {
        Self(role: .user, content: try content())
    }
}
