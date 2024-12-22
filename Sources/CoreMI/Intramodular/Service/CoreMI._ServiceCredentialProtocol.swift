//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

extension CoreMI {
    public protocol _ServiceCredentialProtocol: Codable, Hashable, Sendable {
        var credentialType: CoreMI._ServiceCredentialTypeIdentifier { get }
    }
}

// MARK: - Conformees

extension CoreMI._ServiceCredentialTypes {
    public struct APIKeyCredential: CoreMI._ServiceCredentialProtocol {
        public var credentialType: CoreMI._ServiceCredentialTypeIdentifier {
            CoreMI._ServiceCredentialTypeIdentifier.apiKey
        }
        
        public let apiKey: String
        
        public init(apiKey: String) {
            self.apiKey = apiKey
        }
    }
}

extension CoreMI._ServiceCredentialTypes {
    @HadeanIdentifier("jikok-fafan-nadij-javub")
    public struct PlayHTCredential: CoreMI._ServiceCredentialProtocol {
        public var credentialType: CoreMI._ServiceCredentialTypeIdentifier {
            .custom(Self.self)
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
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "CoreMI._ServiceCredentialTypes.APIKeyCredential")
public typealias _MIServiceAPIKeyCredential = CoreMI._ServiceCredentialTypes.APIKeyCredential
