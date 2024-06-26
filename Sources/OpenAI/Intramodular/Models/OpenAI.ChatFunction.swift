//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import Swift

extension OpenAI {
    public typealias ChatFunction =  __OpenAI_ChatFunction
    public typealias ChatFunctionResult =  __OpenAI_ChatFunctionResult
}

public protocol __OpenAI_ChatFunctionResult: Codable, Hashable, Sendable {
    
}

public protocol __OpenAI_ChatFunction: Initiable {
    associatedtype Result: Codable & Hashable
    
    var name: String { get }
    
    init()
    
    func perform() throws -> Result
}
