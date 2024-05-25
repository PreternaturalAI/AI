//
// Copyright (c) Vatsal Manot
//

import Compute
import CorePersistence
import Foundation
import Swallow

extension AbstractLLM {
    public struct ChatCompletion: Completion {
        public static var _completionType: AbstractLLM.CompletionType? {
            .chat
        }
        
        public let prompt: [AbstractLLM.ChatMessage]
        public let message: AbstractLLM.ChatMessage
        public let stopReason: StopReason?
        
        public init(
            prompt: [AbstractLLM.ChatMessage],
            message: AbstractLLM.ChatMessage,
            stopReason: StopReason? = nil
        ) {
            var prompt = prompt
            var message = message

            if prompt.last?.role == .assistant {
                if message.role == .assistant {
                    var last = prompt.removeLast()
                    
                    last._appendUnsafely(other: message)
                    
                    message = last
                } else {
                    runtimeIssue("This is unexpected.")
                }
            }
            
            self.prompt = prompt
            self.message = message
            self.stopReason = stopReason
        }
    }
}

// MARK: - Extensions

extension AbstractLLM.ChatCompletion {
    public func toString() throws -> String {
        try String(message.content)
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatCompletion: CustomDebugStringConvertible {
    public var debugDescription: String {
        message.debugDescription
    }
}

extension AbstractLLM.ChatCompletion: Partializable {
    public struct Partial: Codable, CustomStringConvertible, Hashable, Sendable {
        public var message: AbstractLLM.ChatMessage.Partial?
        public var stopReason: StopReason?
        
        public var description: String {
            var result: String = ""
            
            if let message {
                result = result + "\(message) "
            }
            
            if let stopReason {
                result = result + "[stop: \(stopReason)] "
            }
            
            return result.trimmingWhitespace()
        }
        
        public init(
            message: AbstractLLM.ChatMessage.Partial?,
            stopReason: StopReason?
        ) {
            self.message = message
            self.stopReason = stopReason
        }
        
        public init(
            delta message: AbstractLLM.ChatMessage
        ) {
            self.message = AbstractLLM.ChatMessage.Partial(delta: message)
            self.stopReason = nil
        }

        public init(
            delta message: some AbstractLLM.ChatMessageConvertible
        ) throws {
            self.init(delta: try message.__conversion())
        }
        
        public init(
            delta completion: AbstractLLM.ChatCompletion
        ) {
            self.init(
                message: .init(delta: completion.message),
                stopReason: completion.stopReason
            )
        }
        
        public init(
            whole completion: AbstractLLM.ChatCompletion
        ) {
            self.init(
                message: .init(whole: completion.message),
                stopReason: completion.stopReason
            )
        }
    }

    public mutating func coalesceInPlace(
        with partial: Partial
    ) throws {
        throw _PartializableTypeError.coalesceInPlaceUnavailable
    }
    
    public static func coalesce(
        _ partials: some Sequence<Partial>
    ) throws -> Self {
        fatalError(.unexpected)
    }
}

// MARK: - Auxiliary

// MARK: - Helpers

extension AbstractLLM.ChatCompletion {
    public var _allFunctionCalls: [AbstractLLM.ChatFunctionCall] {
        self.message.content.stringInterpolation.components.compactMap {
            $0.payload.functionCall
        }
    }
    
    public var _allChatFunctionInvocations: [AbstractLLM.ChatFunctionInvocation] {
        self.message.content.stringInterpolation.components.compactMap {
            $0.payload.functionInvocation
        }
    }
}
