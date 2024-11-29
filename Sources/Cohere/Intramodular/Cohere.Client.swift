//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension Cohere {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            CoreMI._ServiceVendorIdentifier._Cohere
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

extension Cohere.Client: CoreMI._ServiceClientProtocol {
    public convenience init(
        account: (any CoreMI._ServiceAccountProtocol)?
    ) async throws {
        let account: any CoreMI._ServiceAccountProtocol = try account.unwrap()
        let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier = try account.serviceVendorIdentifier.unwrap()

        guard serviceVendorIdentifier == CoreMI._ServiceVendorIdentifier._Cohere else {
            throw CoreMI._ServiceClientError.incompatibleVendor(serviceVendorIdentifier)
        }
        
        guard let credential = try account.credential as? CoreMI._ServiceCredentialTypes.APIKeyCredential else {
            throw CoreMI._ServiceClientError.invalidCredential(try account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}

extension Cohere.Client {
    public typealias CreateCohereEmbedding = Cohere.APISpecification.RequestBodies.CreateEmbedding
    
    public func createEmbeddings(
        for model: Cohere.Model,
        texts: [String],
        inputType: CreateCohereEmbedding.InputType,
        embeddingTypes: [CreateCohereEmbedding.EmbeddingType]?,
        truncate: CreateCohereEmbedding.TruncateStrategy?
    ) async throws -> Cohere.Embeddings {
        try await run(\.createEmbeddings, with: .init(
            model: model,
            texts: texts,
            inputType: inputType,
            embeddingTypes: embeddingTypes,
            truncate: truncate)
        )
    }
}

