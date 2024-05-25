//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

// Specify the expected result type for strongly-typed results. For example, if you're executing a chat completion, the expected result will be a `.string` type.
public struct ChatCompletionDecodableResultType<T: AbstractLLM.ChatCompletionDecodable> {
    fileprivate init() {
        
    }
}

extension ChatCompletionDecodableResultType where T == String {
    public static var string: Self {
        .init()
    }
}

extension ChatCompletionDecodableResultType where T == SwiftUIX._AnyImage {
    public static var image: Self {
        .init()
    }
}

extension ChatCompletionDecodableResultType where T == AbstractLLM.ChatFunctionCall {
    public static var functionCall: Self {
        .init()
    }
}

extension ChatCompletionDecodableResultType where T == Array<AbstractLLM.ChatFunctionCall> {
    public static var functionCalls: Self {
        .init()
    }
}

extension ChatCompletionDecodableResultType where T == AbstractLLM.ChatFunctionInvocation {
    public static var functionInvocation: Self {
        .init()
    }
}

extension ChatCompletionDecodableResultType where T == Array<AbstractLLM.ChatFunctionInvocation> {
    public static var functionInvocations: Self {
        .init()
    }
}
