//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension Mistral {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            _MIServiceTypeIdentifier._Mistral
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
}

extension Mistral.Client: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account: any _MIServiceAccount = try account.unwrap()
        let serviceIdentifier: _MIServiceTypeIdentifier = account.serviceIdentifier

        guard serviceIdentifier == _MIServiceTypeIdentifier._Mistral else {
            throw _MIServiceError.serviceTypeIncompatible(serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}

extension Mistral.Client {
    public func createEmbeddings(
        for input: [String]
    ) async throws -> Mistral.Embeddings {
        try await run(\.createEmbeddings, with: .init(input: input))
    }
}
