//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow
import SwiftDI

/// A context for machine intelligence.
public final class MIContext: ObservableObject {
    @Published public var handlers: [any CoreMI.RequestHandling] = []
    
    public func add<T: CoreMI.RequestHandling>(_ x: T) {
        handlers.append(x)
    }
    
    public func _firstHandler<T>(ofType type: T.Type) async throws -> T {
        try handlers.first(byUnwrapping: { try? cast($0, to: type) }).unwrap()
    }
}

public enum CoreMI {
    public protocol Request {
        
    }
    
    public protocol RequestResult {
        
    }
}
