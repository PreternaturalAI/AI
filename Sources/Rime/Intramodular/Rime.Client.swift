//
//  Rime.Client.swift
//  AI
//
//  Created by Jared Davidson on 11/21/24.
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension Rime {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            _MIServiceTypeIdentifier._Rime
        }
        
        public typealias API = Rime.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(configuration: API.Configuration) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(apiKey: String) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension Rime.Client: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account: any _MIServiceAccount = try account.unwrap()
        let serviceIdentifier: _MIServiceTypeIdentifier = account.serviceIdentifier
        
        guard serviceIdentifier == _MIServiceTypeIdentifier._PlayHT else {
            throw _MIServiceError.serviceTypeIncompatible(serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}

extension Rime.Client {
    public func getAllAvailableVoices() async throws -> [Rime.Voice] {
        try await run(\.listVoices).voices
    }
    
    public func streamTextToSpeech(
        text: String,
        voice: String,
        model: Rime.Model
    ) async throws -> Data {
        
        let input = Rime.APISpecification.RequestBodies.TextToSpeechInput(
            speaker: voice,
            text: text,
            modelId: model.rawValue
        )
        
        let responseData = try await run(\.textToSpeech, with: input)
        
        return responseData.audioData
    }
}
