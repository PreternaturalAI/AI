//
// Copyright (c) Vatsal Manot
//

import Combine
import Swallow
import SwiftDI

/// A context for machine intelligence.
public final class MIContext: ObservableObject {
    @Published public var handlers: [any _MIRequestHandling] = []
    
    public func add<T: _MIRequestHandling>(_ x: T) {
        handlers.append(x)
    }
    
    public func _firstHandler<T>(ofType type: T.Type) async throws -> T {
        try handlers.first(byUnwrapping: { try? cast($0, to: type) }).unwrap()
    }
}

public protocol _MIRequest {
    
}

public protocol _MIResult {
    
}
