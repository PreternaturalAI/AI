//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

@HadeanIdentifier("rajil-pagik-tibah-jibod")
@RuntimeDiscoverable
public enum ModelIdentifierScope: Codable, Hashable, Sendable {
    case one(ModelIdentifier)
    case choiceOf(Set<ModelIdentifier>)
    
    public var _oneValue: ModelIdentifier {
        get throws {
            guard case .one(let value) = self else {
                if case .choiceOf(let set) = self, let value = try set.toCollectionOfOne().first {
                    return value
                }
                
                throw Never.Reason.illegal
            }
            
            return value
        }
    }
    
    public init(_ identifier: ModelIdentifier) {
        self = .one(identifier)
    }
    
    public func `as`<T: ModelIdentifierRepresentable>(
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
