//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

public enum _MIServiceCredentialType: String, PersistentIdentifier {
    case apiKey = "apiKey"
}

public protocol _MIServiceCredential: Codable, Hashable, Sendable {
    var credentialType: _MIServiceCredentialType { get }
}

public struct _MIServiceAPIKeyCredential: _MIServiceCredential {
    public var credentialType: _MIServiceCredentialType {
        _MIServiceCredentialType.apiKey
    }
    
    public let apiKey: String
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
}
