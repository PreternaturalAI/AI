//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import CoreMI
import Swallow

extension AbstractLLM {
    /// The developer-supplied result of a function that you passed to an LLM.
    ///
    /// This is distinct from a _function call_.
    public struct ResultOfFunctionCall: Codable, Hashable, Sendable {
        public let functionID: AnyPersistentIdentifier?
        public let name: AbstractLLM.ChatFunction.Name
        public let result: FunctionResult
        
        public var debugDescription: String {
            "<function invocation of \"\(name)\": \(result)>"
        }
        
        public init(
            functionID: AnyPersistentIdentifier?,
            name: AbstractLLM.ChatFunction.Name,
            result: FunctionResult
        ) {
            self.functionID = functionID
            self.name = name
            self.result = result
        }
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ResultOfFunctionCall {
    public struct FunctionResult: Codable, CustomStringConvertible, Hashable, Sendable {
        public let rawValue: String
        
        public var description: String {
            rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public func __conversion<T>() throws -> T {
            let result: Any
            
            switch T.self {
                case String.self:
                    result = rawValue
                default:
                    TODO.unimplemented
            }
            
            return try cast(result)
        }
    }
}

// MARK: - Deprecated

extension AbstractLLM {
    @available(*, deprecated, renamed: "AbstractLLM.ResultOfFunctionCall")
    public typealias ChatFunctionInvocation = ResultOfFunctionCall
}
