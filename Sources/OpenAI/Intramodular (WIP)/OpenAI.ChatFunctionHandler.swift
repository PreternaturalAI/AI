//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import Swift

extension OpenAI {
    public protocol ChatFunctionHandler: Initiable {
        associatedtype Result: Codable & Hashable
        
        var name: String { get }
        
        init()
        
        func perform() throws -> Result
    }
    
    public protocol ChatFunctionResult: Codable, Hashable, Sendable {
        
    }
}
