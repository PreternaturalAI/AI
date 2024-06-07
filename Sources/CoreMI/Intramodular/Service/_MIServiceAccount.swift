//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

/// An account used to authenticate access to a service.
public protocol _MIServiceAccount: Hashable {
    var serviceIdentifier: _MIServiceTypeIdentifier { get }
    var credential: (any _MIServiceCredential)? { get }
}

public struct _AnyMIServiceAccount: _MIServiceAccount {
    public let serviceIdentifier: _MIServiceTypeIdentifier
    @_HashableExistential
    public var credential: (any _MIServiceCredential)?
    
    public init(
        serviceIdentifier: _MIServiceTypeIdentifier,
        credential: (any _MIServiceCredential)?
    ) {
        self.serviceIdentifier = serviceIdentifier
        self.credential = credential
    }
}
