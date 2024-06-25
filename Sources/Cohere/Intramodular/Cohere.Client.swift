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
            _MIServiceTypeIdentifier._Cohere
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

extension Cohere.Client: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account: any _MIServiceAccount = try account.unwrap()
        let serviceIdentifier: _MIServiceTypeIdentifier = account.serviceIdentifier

        guard serviceIdentifier == _MIServiceTypeIdentifier._Cohere else {
            throw _MIServiceError.serviceTypeIncompatible(serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
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

