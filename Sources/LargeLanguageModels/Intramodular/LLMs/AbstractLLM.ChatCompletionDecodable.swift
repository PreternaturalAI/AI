//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

extension AbstractLLM {
    /// A type that can be decoded as a result of a completion.
    public protocol ChatCompletionDecodable {
        static func decode(
            _ type: Self.Type,
            from completion: AbstractLLM.ChatCompletion
        ) async throws -> Self
        
        static func decode(
            _ type: Array<Self>.Type,
            from completion: AbstractLLM.ChatCompletion
        ) async throws -> Array<Self>
    }
}

extension AbstractLLM.ChatCompletionDecodable {
    public static func decode(
        _ type: Array<Self>.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Array<Self> {
        throw Never.Reason.illegal
    }
}

// MARK: - Internal

extension AbstractLLM.ChatCompletion {
    func _decode<Result: AbstractLLM.ChatCompletionDecodable>(
        as type: Result.Type
    ) async throws -> Result {
        try await type.decode(type, from: self)
    }
    
    func _decode<Result: AbstractLLM.ChatCompletionDecodable>(
        as type: Array<Result>.Type
    ) async throws -> Array<Result> {
        try await type.decode(type, from: self)
    }
}

// MARK: - Implemented Conformances

extension AbstractLLM.ChatFunctionCall: AbstractLLM.ChatCompletionDecodable {
    public static func decode(
        _ type: Self.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        try completion._allFunctionCalls.toCollectionOfOne().first
    }
    
    public static func decode(
        _ type: Array<Self>.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Array<Self> {
        completion._allFunctionCalls
    }
}

extension AbstractLLM.ChatFunctionInvocation: AbstractLLM.ChatCompletionDecodable {
    public static func decode(
        _ type: Self.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        try completion._allChatFunctionInvocations.toCollectionOfOne().first
    }
    
    public static func decode(
        _ type: Array<Self>.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Array<Self> {
        completion._allChatFunctionInvocations
    }
}

extension String: AbstractLLM.ChatCompletionDecodable {
    public static func decode(
        _ type: Self.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        try String(completion.message.content)
    }
}

extension SwiftUIX._AnyImage: AbstractLLM.ChatCompletionDecodable {
    @MainActor
    public static func decode(
        _ type: Self.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        try await completion.message
            .content
            .promptLiteral
            .stringInterpolation
            .components
            .firstAndOnly(byUnwrapping: {
                (payload) -> SwiftUIX._AnyImage? in
                guard case .image(let image) = payload.payload else {
                    return nil
                }
                
                return try await image._toAppKitOrUIKitImage()
            })
            .unwrap()
    }
}

extension Array: AbstractLLM.ChatCompletionDecodable where Element: AbstractLLM.ChatCompletionDecodable {
    @MainActor
    public static func decode(
        _ type: Self.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        try await completion._decode(as: self)
    }
}
