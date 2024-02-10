//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import Swallow

public final class Anthropic: HTTPClient, PersistentlyRepresentableType, _StaticNamespaceType {
    public static var persistentTypeRepresentation: some IdentityRepresentation {
        _GMLModelServiceTypeIdentifier._Anthropic
    }
    
    public let interface: API
    public let session: HTTPSession
    
    public init(interface: API, session: HTTPSession) {
        self.interface = interface
        self.session = session
    }
    
    public convenience init(apiKey: String?) {
        self.init(
            interface: .init(configuration: .init(apiKey: apiKey)),
            session: .shared
        )
    }
}

// MARK: - Conformances

extension Anthropic: _GMLModelService {
    public convenience init(
        account: (any _GMLModelServiceAccount)?
    ) async throws {
        let account = try account.unwrap()
        
        guard account.serviceIdentifier == _GMLModelServiceTypeIdentifier._Anthropic else {
            throw _GMLModelServiceError.incompatibleServiceType(account.serviceIdentifier)
        }
        
        guard let credential = account.credential as? _GMLModelServiceAPIKeyCredential else {
            throw _GMLModelServiceError.invalidCredential(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
