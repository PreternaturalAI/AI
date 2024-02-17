//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

/// A machine intelligence service.
public protocol _MIService: PersistentlyRepresentableType {
    init(account: (any _MIServiceAccount)?) async throws
}

public enum _MIServiceError: Error {
    case serviceTypeIncompatible(_MIServiceTypeIdentifier)
    case invalidCredentials((any _MIServiceCredential)?)
}
