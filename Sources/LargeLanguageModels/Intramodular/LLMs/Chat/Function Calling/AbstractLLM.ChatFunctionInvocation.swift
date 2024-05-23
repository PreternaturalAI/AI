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
    public struct ChatFunctionInvocation: Codable, Hashable, Sendable {
        public struct FunctionResult: Codable, Hashable, Sendable {
            public let rawValue: String
            
            public init(rawValue: String) {
                self.rawValue = rawValue
            }
        }
        
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
