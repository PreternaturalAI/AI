//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import Swallow

public final class Anthropic: HTTPClient, PersistentlyRepresentableType, _StaticNamespaceType {
    public static var persistentTypeRepresentation: some IdentityRepresentation {
        _MIServiceTypeIdentifier._Anthropic
    }
    
    public let interface: API
    public let session: HTTPSession
    
    public init(interface: API, session: HTTPSession) {
        self.interface = interface
        self.session = session
        
        session.disableTimeouts()
    }
    
    public convenience init(apiKey: String?) {
        self.init(
            interface: API(configuration: .init(apiKey: apiKey)),
            session: .shared
        )
    }
}

// MARK: - Conformances

extension Anthropic: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account = try account.unwrap()
        
        guard account.serviceIdentifier == _MIServiceTypeIdentifier._Anthropic else {
            throw _MIServiceError.serviceTypeIncompatible(account.serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
