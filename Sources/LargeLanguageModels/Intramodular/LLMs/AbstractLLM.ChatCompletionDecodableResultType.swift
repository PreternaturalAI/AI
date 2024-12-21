//
// Copyright (c) Preternatural AI, Inc.
//

import Swallow
import SwiftUIX

extension AbstractLLM {
    // Specify the expected result type for strongly-typed results. For example, if you're executing a chat completion, the expected result will be a `.string` type.
    public struct ChatCompletionDecodableResultType<T: AbstractLLM.ChatCompletionDecodable> {
        fileprivate init() {
            
        }
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType where T == String {
    public static var string: Self {
        .init()
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType where T == SwiftUIX._AnyImage {
    public static var image: Self {
        .init()
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType where T == AbstractLLM.ChatMessage {
    public static var chatMessage: Self {
        .init()
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType where T == AbstractLLM.ChatFunctionCall {
    public static var functionCall: Self {
        .init()
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType where T == Array<AbstractLLM.ChatFunctionCall> {
    public static var functionCalls: Self {
        .init()
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType where T == AbstractLLM.ResultOfFunctionCall {
    public static var functionInvocation: Self {
        .init()
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType where T == Array<AbstractLLM.ResultOfFunctionCall> {
    public static var functionInvocations: Self {
        .init()
    }
}

extension AbstractLLM.ChatCompletionDecodableResultType {
    public static func either<LHS: AbstractLLM.ChatCompletionDecodable, RHS: AbstractLLM.ChatCompletionDecodable>(
        _ lhs: AbstractLLM.ChatCompletionDecodableResultType<LHS>,
        or rhs: AbstractLLM.ChatCompletionDecodableResultType<RHS>
    ) -> Self where Self == AbstractLLM.ChatCompletionDecodableResultType<Either<LHS, RHS>> {
        .init()
    }
}
