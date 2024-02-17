//
// Copyright (c) Vatsal Manot
//


import Foundation

/// A type that handles generative machine learning requests.
public protocol _MIRequestHandling {
    func consider<R: _MIRequest>(_ request: R) async throws -> _MIRequestConsideration
    
    func perform<Request: _MIRequest, Result: _MIResult>(
        _ request: Request,
        returning resultType: Result.Type
    ) async throws -> Result
}

extension _MIRequestHandling {
    public func consider<R: _MIRequest>(_ request: R) -> _MIRequestConsideration {
        _MIRequestConsideration()
    }
    
    public func perform<Request: _MIRequest, Result: _MIResult>(
        _ request: Request,
        returning resultType: Result.Type
    ) async throws -> Result {
        fatalError()
    }
}

public struct _MIRequestConsideration {
    
}
