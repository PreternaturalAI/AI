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
        
        public struct FunctionCall: Codable, CustomDebugStringConvertible, Hashable, Sendable {
            public let name: String
            public let arguments: String
            public var context: PromptContextValues
            
            public var debugDescription: String {
                "<function call: \(name)>"
            }
            
            public init(
                name: String,
                arguments: String,
                context: PromptContextValues
            ) {
                self.name = name
                self.arguments = arguments
                self.context = context
            }
            
            /// Decodes the given type assuming that the function call's arguments are expressed in JSON
            public func decode<T: Decodable>(
                _ type: T.Type
            ) throws -> T {
                let json = try JSON(jsonString: arguments)
                
                do {
                    return try json.decode(type, keyDecodingStrategy: .convertFromSnakeCase)
                } catch(let error) {
                    do {
                        defer {
                            runtimeIssue("Recovered by using camel case.")
                        }
                        
                        return try json.decode(type)
                    } catch(_) {
                        throw error
                    }
                }
            }
        }
        
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

// MARK: - Auxiliary

extension AbstractLLM.ChatPrompt {
    public struct FunctionResult: Codable, Hashable, Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
    }
    
    public struct RawFunctionInvocation: Codable, Hashable, Sendable {
        public let name: String
        public let result: FunctionResult
        
        public var debugDescription: String {
            "<function invocation: \(name)>"
        }
        
        public init(name: String, result: FunctionResult) {
            self.name = name
            self.result = result
        }
    }
}
