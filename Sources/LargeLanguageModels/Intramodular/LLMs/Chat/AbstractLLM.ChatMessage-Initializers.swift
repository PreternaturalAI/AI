//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Swallow
import SwiftUIX

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
                    functionID: nil, // FIXME: !!!
                    name: function.name,
                    arguments: .init(unencoded: arguments.prettyPrintedDescription),
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
        _ functionInvocation: AbstractLLM.ResultOfFunctionCall
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
