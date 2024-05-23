//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

extension AbstractLLM {
    /// A chat prompt that can be sent to an LLM service to generate a completion.
    public struct ChatPrompt: AbstractLLM.Prompt, Hashable, Sendable {
        public typealias CompletionParameters = AbstractLLM.ChatCompletionParameters
        public typealias Completion = AbstractLLM.ChatCompletion
        
        public static var completionType: AbstractLLM.CompletionType? {
            .chat
        }
        
        public var messages: [AbstractLLM.ChatMessage]
        public var context: PromptContextValues {
            didSet {
                if context.completionType != nil {
                    assert(context.completionType == .chat)
                } else {
                    context.completionType = .chat
                }
            }
        }
        
        public init(
            messages: [AbstractLLM.ChatMessage],
            context: PromptContextValues = PromptContextValues.current
        ) {
            self.messages = messages
            self.context = context
            
            if context.completionType != nil {
                assert(context.completionType == .chat)
            }
        }
        
        public init(
            _ messages: () -> [AbstractLLM.ChatMessage]
        ) {
            self.init(messages: messages())
        }
    }
}

extension AbstractLLM.ChatPrompt {
    public var _rawContent: PromptLiteral {
        get throws {
            // FIXME: !!!
            // This currently discards role and possibly other metadata
            
            return PromptLiteral.concatenate(separator: nil) {
                messages.map({ $0.content })
            }
        }
    }
}

extension AbstractLLM.ChatPrompt {
    public mutating func append(
        _ message: AbstractLLM.ChatMessage
    ) {
        messages.append(message)
    }
    
    public func appending(
        _ message: AbstractLLM.ChatMessage
    ) -> Self {
        withMutableScope(self) {
            $0.append(message)
        }
    }
    
    public func appending(
        _ message: () -> AbstractLLM.ChatMessage
    ) -> Self {
        appending(message())
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatPrompt: CustomDebugStringConvertible {
    public var debugDescription: String {
        messages
            .map({ $0.debugDescription })
            .joined(separator: .init(Character.newline))
    }
}

extension AbstractLLM.ChatPrompt: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: AbstractLLM.ChatMessage...) {
        self.init(messages: elements, context: PromptContextValues.current)
    }
}
