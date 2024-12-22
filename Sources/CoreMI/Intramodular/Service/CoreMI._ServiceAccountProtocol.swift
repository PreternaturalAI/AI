//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

extension CoreMI {
    /// An account used to authenticate access to a service.
    public protocol _ServiceAccountProtocol: Hashable {
        var serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier? { get throws }
        var credential: (any CoreMI._ServiceCredentialProtocol)? { get throws }
    }
    
    public struct _AnyServiceAccount: CoreMI._ServiceAccountProtocol {
        public let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier?
        @_HashableExistential
        public var credential: (any CoreMI._ServiceCredentialProtocol)?
        
        public init(
            serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier?,
            credential: (any CoreMI._ServiceCredentialProtocol)?
        ) {
            self.serviceVendorIdentifier = serviceVendorIdentifier
            self.credential = credential
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated)
public typealias _MIServiceAccount = CoreMI._ServiceAccountProtocol
@available(*, deprecated)
public typealias _AnyMIServiceAccount = CoreMI._AnyServiceAccount
