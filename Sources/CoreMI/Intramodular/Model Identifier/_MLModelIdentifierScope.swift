//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

@HadeanIdentifier("rajil-pagik-tibah-jibod")
@RuntimeDiscoverable
public enum _MLModelIdentifierScope: Codable, Hashable, Sendable {
    case one(_MLModelIdentifier)
    case choiceOf(Set<_MLModelIdentifier>)
    
    public var _oneValue: _MLModelIdentifier? {
        guard case .one(let value) = self else {
            if case .choiceOf(let set) = self, let value = try? set.toCollectionOfOne().first {
                return value
            }
            
            return nil
        }
        
        return value
    }
    
    public init(_ identifier: _MLModelIdentifier) {
        self = .one(identifier)
    }
    
    public func `as`<T: _MLModelIdentifierRepresentable>(
        _ type: T.Type
    ) throws -> T {
        switch self {
            case .one(let identifier):
                return try T(from: identifier)
            case .choiceOf(let identifiers):
                return try identifiers.compactMap({ try? T(from: $0) }).toCollectionOfOne().first
        }
    }
}
