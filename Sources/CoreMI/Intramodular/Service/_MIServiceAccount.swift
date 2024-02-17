//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _MIServiceAccount {
    var serviceIdentifier: _MIServiceTypeIdentifier { get }
    var credential: (any _MIServiceCredential)? { get }
}

public struct _AnyMIModelServiceAccount: _MIServiceAccount {
    public let serviceIdentifier: _MIServiceTypeIdentifier
    public let credential: (any _MIServiceCredential)?
    
    public init(
        serviceIdentifier: _MIServiceTypeIdentifier,
        credential: (any _MIServiceCredential)?
    ) {
        self.serviceIdentifier = serviceIdentifier
        self.credential = credential
    }
}
