//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension NeetsAI {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            CoreMI._ServiceVendorIdentifier._NeetsAI
        }
        
        public typealias API = NeetsAI.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(
            configuration: API.Configuration
        ) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(
            apiKey: String
        ) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension NeetsAI.Client {
    public func getAllAvailableVoices() async throws -> [NeetsAI.Voice] {
        try await run(\.listVoices)
    }
    
    public func generateSpeech(
        text: String,
        voiceId: String,
        model: NeetsAI.Model = .arDiff50k,
        temperature: Double = 1,
        diffusionIterations: Int = 5
    ) async throws -> Data {
        let input = API.RequestBodies.TTSInput(
            params: .init(
                model: model.rawValue,
                temperature: temperature,
                diffusionIterations: diffusionIterations
            ),
            text: text,
            voiceId: voiceId
        )
        
        return try await run(\.generateSpeech, with: input)
    }
    
    public func chat(
        messages: [NeetsAI.ChatMessage],
        model: NeetsAI.Model = .mistralai
    ) async throws -> NeetsAI.ChatCompletion {
        let input = API.RequestBodies.ChatInput(
            messages: messages,
            model: model.rawValue
        )
        
        return try await run(\.chatCompletion, with: input)
    }
}

// MARK: - Conformances

extension NeetsAI.Client: CoreMI._ServiceClientProtocol {
    public convenience init(
        account: (any CoreMI._ServiceAccountProtocol)?
    ) async throws {
        let account: any CoreMI._ServiceAccountProtocol = try account.unwrap()
        let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier = try account.serviceVendorIdentifier.unwrap()
        
        guard serviceVendorIdentifier == CoreMI._ServiceVendorIdentifier._NeetsAI else {
            throw CoreMI._ServiceClientError.incompatibleVendor(serviceVendorIdentifier)
        }
        
        guard let credential = try account.credential as? CoreMI._ServiceCredentialTypes.APIKeyCredential else {
            throw CoreMI._ServiceClientError.invalidCredential(try account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
