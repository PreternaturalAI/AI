//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

public enum _MIServiceCredentialType: String, PersistentIdentifier {
    case apiKey = "apiKey"
    case userIDAndAPIKey = "userIDAndAPIKey"
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

public struct _MIServiceUserIDAndAPIKeyCredential: _MIServiceCredential {
    public var credentialType: _MIServiceCredentialType {
        _MIServiceCredentialType.userIDAndAPIKey
    }
    
    public let userID: String
    public let apiKey: String
    
    public init(
        userID: String,
        apiKey: String
    ) {
        self.userID = userID
        self.apiKey = apiKey
    }
}
