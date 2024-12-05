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

// MARK: - Conformees

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

extension AbstractLLM.ChatMessage: AbstractLLM.ChatCompletionDecodable {
    public static func decode(
        _ type: Self.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        completion.message
    }
    
    public static func decode(
        _ type: Array<Self>.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Array<Self> {
        [completion.message]
    }
}

extension AbstractLLM.ResultOfFunctionCall: AbstractLLM.ChatCompletionDecodable {
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

extension Either: AbstractLLM.ChatCompletionDecodable where LeftValue: AbstractLLM.ChatCompletionDecodable, RightValue: AbstractLLM.ChatCompletionDecodable {
    public static func decode(
        _ type: Self.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        do {
            return try await .left(LeftValue.decode(LeftValue.self, from: completion))
        } catch {
            return try await .right(RightValue.decode(RightValue.self, from: completion))
        }
    }
    
    public static func decode(
        _ type: Array<Self>.Type,
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Array<Self> {
        do {
            return try await LeftValue.decode([LeftValue].self, from: completion).map({ Self.left($0) })
        } catch {
            return try await RightValue.decode([RightValue].self, from: completion).map({ Self.right($0) })
        }
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
