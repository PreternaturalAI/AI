//
// Copyright (c) Vatsal Manot
//

import Combine
import SwiftDI

/// A context for machine intelligence.
public final class MIContext: ObservableObject {
    @Published public var handlers: [any _MIRequestHandling] = []
        
    public func add<T: _MIRequestHandling>(_ x: T) {
        handlers.append(x)
    }
}

public protocol _MIRequest {
    
}

public protocol _MIResult {
    
}
