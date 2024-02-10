//
// Copyright (c) Vatsal Manot
//

import Swift

public protocol _GMLModelServiceAccount {
    var serviceIdentifier: _GMLModelServiceTypeIdentifier { get }
    var credential: (any _GMLModelServiceCredential)? { get }
}

public struct _AnyGMLModelServiceAccount: _GMLModelServiceAccount {
    public let serviceIdentifier: _GMLModelServiceTypeIdentifier
    public let credential: (any _GMLModelServiceCredential)?
    
    public init(
        serviceIdentifier: _GMLModelServiceTypeIdentifier,
        credential: (any _GMLModelServiceCredential)?
    ) {
        self.serviceIdentifier = serviceIdentifier
        self.credential = credential
    }
}
