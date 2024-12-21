//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Swallow

extension CoreMI {
    /// A client for an AI/ML service.
    public protocol _ServiceClientProtocol: PersistentlyRepresentableType {
        init(account: (any CoreMI._ServiceAccountProtocol)?) async throws
    }
    
    public enum _ServiceClientError: Error {
        case incompatibleVendor(CoreMI._ServiceVendorIdentifier)
        case invalidCredential((any CoreMI._ServiceCredentialProtocol)?)
        
        public static var invalidCredential: Self {
            Self.invalidCredential(nil)
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated)
public typealias _MIService = CoreMI._ServiceClientProtocol
@available(*, deprecated)
public typealias _MIServiceError = CoreMI._ServiceClientError
