//
// Copyright (c) Vatsal Manot
//

import Swallow

extension AbstractLLM.ChatOrTextCompletion {
    public func _stripToText() throws -> String {
        switch self {
            case .text(let completion):
                return completion.text
            case .chat(let completion):
                return try completion._stripToText()
        }
    }
}

extension PromptLiteral {
    public func _stripToText() throws -> String {
        try stringInterpolation.components.map({ try $0._stripToText() }).joined()
    }
}

extension PromptLiteral.StringInterpolation.Component {
    public func _stripToText() throws -> String {
        switch payload {
            case .stringLiteral(let value):
                return value
            case .image:
                throw Never.Reason.illegal
            case .localizedStringResource(let value):
                return try value._toNSLocalizedString()
            case .promptLiteralConvertible(let value):
                return try value.promptLiteral.merging(context)._stripToText()
            case .dynamicVariable(let variable):
                return try variable.promptLiteral._stripToText()
            case .other(let other):
                switch other {
                    case .functionCall:
                        throw Never.Reason.illegal
                    case .functionInvocation:
                        throw Never.Reason.illegal
                }
        }
    }
}

extension AbstractLLM.ChatMessage {
    /// FIXME: !!!
    public func _stripToText() throws -> String {
        try content._stripToText()
    }
}

extension AbstractLLM.ChatPrompt {
    /// FIXME: !!!
    public func _stripToText() throws -> String {
        try messages.map({ try $0._stripToText() }).joined()
    }
}

extension AbstractLLM.ChatCompletion {
    public func _stripToText() throws -> String {
        try message.content._stripToText()
    }
}

extension String {
    public init(_ promptLiteral: PromptLiteral) throws {
        self = try promptLiteral._stripToText()
    }
}
