//
// Copyright (c) Preternatural AI, Inc.
//

import Compute
import Foundation
import Swallow

extension AbstractLLM {
    public enum CompletionType: String, CaseIterable, Codable, Hashable, Sendable {
        case text = "text"
        case chat = "chat"
    }
    
    public protocol Prompt: Codable, Hashable, Sendable {
        associatedtype CompletionParameters: AbstractLLM.CompletionParameters
        associatedtype Completion: Partializable
        
        static var knownCompletionType: AbstractLLM.CompletionType? { get }
        
        var context: PromptContextValues { get set }
    }
}

extension AbstractLLM {
    public enum ChatOrTextPrompt: Prompt {
        public typealias CompletionParameters = ChatOrTextCompletionParameters
        public typealias Completion = AbstractLLM.ChatOrTextCompletion
        
        public static var knownCompletionType: AbstractLLM.CompletionType? {
            nil
        }
        
        public var context: PromptContextValues {
            get {
                switch self {
                    case .text(let prompt):
                        return prompt.context
                    case .chat(let prompt):
                        return prompt.context
                }
            } set {
                switch self {
                    case .text(var prompt):
                        prompt.context = newValue
                        
                        self = .text(prompt)
                    case .chat(var prompt):
                        prompt.context = newValue
                        
                        self = .chat(prompt)
                }
            }
        }
        
        case text(TextPrompt)
        case chat(ChatPrompt)
        
        public var textPrompt: TextPrompt? {
            guard case .text(let prompt) = self else {
                return nil
            }

            return prompt
        }
        
        public var chatPrompt: ChatPrompt? {
            guard case .chat(let prompt) = self else {
                return nil
            }
            
            return prompt
        }
    }
}

// MARK: - Extensions

extension AbstractLLM.ChatOrTextPrompt {
    public var completionType: AbstractLLM.CompletionType {
        switch self {
            case .text:
                return .text
            case .chat:
                return .chat
        }
    }
    
    public static func chat(
        _ messages: () -> [AbstractLLM.ChatMessage]
    ) -> Self {
        .chat(AbstractLLM.ChatPrompt(messages: messages(), context: PromptContextValues.current))
    }
    
    public static func text(_ literal: any PromptLiteralConvertible) -> Self {
        .text(AbstractLLM.TextPrompt(prefix: literal))
    }
    
    public func appending(
        _ text: String
    ) throws -> AbstractLLM.ChatOrTextPrompt {
        switch self {
            case .text(let value):
                return .text(.init(prefix: PromptLiteral(_lazy: value.prefix) + PromptLiteral(stringLiteral: text)))
            case .chat(let value):
                return .chat(value.appending(.user(text)))
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatOrTextCompletion: Partializable {
    public enum Partial {
        case text(AbstractLLM.TextCompletion.Partial)
        case chat(AbstractLLM.ChatCompletion.Partial)
    }
    
    public mutating func coalesceInPlace(
        with partial: Partial
    ) throws {
        switch (self, partial) {
            case (.text(var lhs), .text(let rhs)):
                try lhs.coalesceInPlace(with: rhs)
                
                self = .text(lhs)
            case (.chat(var lhs), .chat(let rhs)):
                try lhs.coalesceInPlace(with: rhs)
                
                self = .chat(lhs)
            default:
                assertionFailure()
                
                break
        }
    }
    
    public static func coalesce(
        _ partials: some Sequence<Partial>
    ) throws -> Self {
        fatalError()
    }
}

extension AbstractLLM.ChatOrTextPrompt: _UnwrappableTypeEraser {
    public typealias _UnwrappedBaseType = any AbstractLLM.Prompt
    
    public init(_erasing prompt: _UnwrappedBaseType) {
        assert(!(prompt is Self))
        
        switch prompt {
            case let prompt as AbstractLLM.TextPrompt:
                self = .text(prompt)
            case let prompt as AbstractLLM.ChatPrompt:
                self = .chat(prompt)
            default:
                fatalError(.unexpected)
        }
    }
    
    public func _unwrapBase() -> _UnwrappedBaseType {
        switch self {
            case .text(let prompt):
                return prompt
            case .chat(let prompt):
                return prompt
        }
    }
}
