//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Swallow

extension AbstractLLM {
    /// The function call as called by the LLM.
    ///
    /// This is essentially just the LLM generating the name of the function along with its arguments.
    public struct ChatFunctionCall: Codable, CustomDebugStringConvertible, Hashable, Sendable {
        @available(*, deprecated, renamed: "AbstractLLM.ChatFunction.Name")
        public typealias Name = AbstractLLM.ChatFunction.Name
        
        public let functionID: AnyPersistentIdentifier?
        public let name: AbstractLLM.ChatFunction.Name
        public let arguments: Arguments
        public var context: PromptContextValues
        
        public var debugDescription: String {
            "<function call: \(name)>"
        }
        
        public init(
            functionID: AnyPersistentIdentifier?,
            name: AbstractLLM.ChatFunction.Name,
            arguments: Arguments,
            context: PromptContextValues
        ) {
            self.functionID = functionID
            self.name = name
            self.arguments = arguments
            self.context = context
        }
        
        @_disfavoredOverload
        public init(
            functionID: AnyPersistentIdentifier?,
            name: String,
            arguments: Arguments,
            context: PromptContextValues
        ) {
            self.init(
                functionID: functionID,
                name: AbstractLLM.ChatFunction.Name(rawValue: name),
                arguments: arguments,
                context: context
            )
        }
    }
}

extension AbstractLLM.ChatFunctionCall.Arguments {
    public func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        do {
            let json: JSON = try __conversion()
            
            do {
                return try json.decode(type, keyDecodingStrategy: .convertFromSnakeCase)
            } catch(let error) {
                do {
                    return try json.decode(type)
                } catch(_) {
                    throw error
                }
            }
        } catch {
            throw error
        }
    }
}

extension AbstractLLM.ChatFunctionCall {
    /// Decodes the given type assuming that the function call's arguments are expressed in JSON.
    public func decode<T: Decodable>(
        _ type: T.Type
    ) throws -> T {
        try arguments.decode(type)
    }
}

extension AbstractLLM.ChatFunctionCall {
    public struct Arguments: Codable, Hashable, Sendable {
        public enum Payload: Codable, Hashable, Sendable {
            case undecoded(String)
            case data([AnyCodingKey: AnyCodable])
        }
        
        public let payload: Payload
        
        public init(payload: Payload) {
            self.payload = payload
        }
        
        public init(unencoded string: String) {
            self.init(payload: .undecoded(string))
        }
        
        public init(json: JSON) {
            self.init(payload: .undecoded(json.prettyPrintedDescription))
        }
        
        public init(_ data: [AnyCodingKey: AnyCodable]) {
            self.init(payload: .data(data))
        }
        
        public init(_ data: [String: AnyCodable]) {
            self.init(data.mapKeys({ AnyCodingKey(stringValue: $0) }))
        }
        
        public func __conversion<T>() throws -> T {
            let result: Any
            
            switch payload {
                case .undecoded(let string):
                    switch T.self {
                        case JSON.self:
                            result = try JSON(jsonString: string)
                        case String.self:
                            result = string
                        default:
                            TODO.unimplemented
                    }
                case .data:
                    TODO.unimplemented
            }
            
            return try cast(result)
        }
    }
}
