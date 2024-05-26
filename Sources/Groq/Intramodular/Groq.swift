//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/26/24.
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

@RuntimeDiscoverable
public final class Groq: HTTPClient, _StaticNamespaceType {
    public static var persistentTypeRepresentation: some IdentityRepresentation {
        _MIServiceTypeIdentifier._Groq
    }
    
    public let interface: APISpecification
    public let session: HTTPSession
    
    public init(interface: APISpecification, session: HTTPSession) {
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

extension Groq: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account = try account.unwrap()
        
        guard account.serviceIdentifier == _MIServiceTypeIdentifier._Groq else {
            throw _MIServiceError.serviceTypeIncompatible(account.serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
