//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

public enum _GMLModelServiceCredentialType: String, PersistentIdentifier {
    case apiKey = "apiKey"
}

public protocol _GMLModelServiceCredential: Codable, Hashable, Sendable {
    var credentialType: _GMLModelServiceCredentialType { get }
}

public struct _GMLModelServiceAPIKeyCredential: _GMLModelServiceCredential {
    public var credentialType: _GMLModelServiceCredentialType {
        _GMLModelServiceCredentialType.apiKey
    }
    
    public let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}
