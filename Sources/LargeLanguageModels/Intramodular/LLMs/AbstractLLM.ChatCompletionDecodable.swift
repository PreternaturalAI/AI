//
// Copyright (c) Vatsal Manot
//

import Swallow
import SwiftUIX

extension AbstractLLM {
    /// A type that can be decoded as a result of a completion.
    public protocol ChatCompletionDecodable {
        static func decode(
            from completion: AbstractLLM.ChatCompletion
        ) async throws -> Self
    }
}

// MARK: - Internal

extension AbstractLLM.ChatCompletion {
    func _decode<Result: AbstractLLM.ChatCompletionDecodable>(
        as type: Result.Type
    ) async throws -> Result {
        try await type.decode(from: self)
    }
}

// MARK: - Implemented Conformances

extension String: AbstractLLM.ChatCompletionDecodable {
    public static func decode(
        from completion: AbstractLLM.ChatCompletion
    ) async throws -> Self {
        try String(completion.message.content)
    }
}

extension SwiftUIX._AnyImage: AbstractLLM.ChatCompletionDecodable {
    @MainActor
    public static func decode(
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
