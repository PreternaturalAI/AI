//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

extension AbstractLLM {
    /// The function call as called by the LLM.
    ///
    /// This is essentially just the LLM generating the name of the function along with its arguments.
    public struct ChatFunctionCall: Codable, CustomDebugStringConvertible, Hashable, Sendable {
        public let name: Name
        public let arguments: String
        public var context: PromptContextValues
        
        public var debugDescription: String {
            "<function call: \(name)>"
        }
        
        public init(
            name: Name,
            arguments: String,
            context: PromptContextValues
        ) {
            self.name = name
            self.arguments = arguments
            self.context = context
        }
        
        @_disfavoredOverload
        public init(
            name: String,
            arguments: String,
            context: PromptContextValues
        ) {
            self.init(
                name: .init(rawValue: name),
                arguments: arguments,
                context: context
            )
        }
    }
}

extension AbstractLLM.ChatFunctionCall {
    /// Decodes the given type assuming that the function call's arguments are expressed in JSON
    public func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        let json = try JSON(jsonString: arguments)
        
        do {
            return try json.decode(type, keyDecodingStrategy: .convertFromSnakeCase)
        } catch(let error) {
            do {
                return try json.decode(type)
            } catch(_) {
                throw error
            }
        }
    }
}

extension AbstractLLM.ChatFunctionCall {
    public struct Name: Codable, ExpressibleByStringLiteral, Hashable, Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
        
        public init(from decoder: any Decoder) throws {
            try self.init(rawValue: String(from: decoder))
        }
        
        public func encode(to encoder: any Encoder) throws {
            try rawValue.encode(to: encoder)
        }
    }
}
