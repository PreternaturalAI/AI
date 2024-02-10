//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

public protocol _GMLModelService: PersistentlyRepresentableType {
    init(account: (any _GMLModelServiceAccount)?) async throws
}

public enum _GMLModelServiceError: Error {
    case incompatibleServiceType(_GMLModelServiceTypeIdentifier)
    case invalidCredential((any _GMLModelServiceCredential)?)
}
