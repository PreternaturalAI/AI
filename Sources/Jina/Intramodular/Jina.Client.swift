//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension Jina {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            CoreMI._ServiceVendorIdentifier._Jina
        }
        
        public let interface: APISpecification
        public let session: HTTPSession
        
        public init(interface: APISpecification, session: HTTPSession) {
            self.interface = interface
            self.session = session
        }
        
        public convenience init(apiKey: String) {
            self.init(
                interface: .init(configuration: .init(apiKey: apiKey)),
                session: .shared
            )
        }
    }
}

extension Jina.Client: CoreMI._ServiceClientProtocol {
    public convenience init(
        account: (any CoreMI._ServiceAccountProtocol)?
    ) async throws {
        let account: any CoreMI._ServiceAccountProtocol = try account.unwrap()
        let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier = try account.serviceVendorIdentifier.unwrap()

        guard serviceVendorIdentifier == CoreMI._ServiceVendorIdentifier._Jina else {
            throw CoreMI._ServiceClientError.incompatibleVendor(serviceVendorIdentifier)
        }
        
        guard let credential = try account.credential as? CoreMI._ServiceCredentialTypes.APIKeyCredential else {
            throw CoreMI._ServiceClientError.invalidCredential(try account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}

extension Jina.Client {
    public func createEmbeddings(
        for model: Jina.Model,
        input: [String],
        encodingFormat: [Jina.APISpecification.RequestBodies.CreateEmbedding.EncodingFormat]?
    ) async throws -> Jina.Embeddings {
        try await run(\.createEmbeddings, with: .init(model: model, input: input, encodingFormat: encodingFormat))
    }
}
