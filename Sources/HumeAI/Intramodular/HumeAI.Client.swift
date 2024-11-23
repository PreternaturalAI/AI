//
//  HumeAI.Clent.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension HumeAI {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            CoreMI._ServiceVendorIdentifier._HumeAI
        }
        
        public typealias API = HumeAI.APISpecification
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

extension HumeAI.Client {
    // Text to Speech
    public func getAllAvailableVoices() async throws -> [HumeAI.Voice] {
        let response = try await run(\.listVoices)
        return response.voices
    }
    
    public func generateSpeech(
        text: String,
        voiceID: String,
        speed: Double? = nil,
        stability: Double? = nil,
        similarityBoost: Double? = nil,
        styleExaggeration: Double? = nil
    ) async throws -> Data {
        let input = HumeAI.APISpecification.RequestBodies.TTSInput(
            text: text,
            voiceId: voiceID,
            speed: speed,
            stability: stability,
            similarityBoost: similarityBoost,
            styleExaggeration: styleExaggeration
        )
        
        return try await run(\.generateSpeech, with: input).audio
    }
    
    public func generateSpeechStream(
        text: String,
        voiceID: String,
        speed: Double? = nil,
        stability: Double? = nil,
        similarityBoost: Double? = nil,
        styleExaggeration: Double? = nil
    ) async throws -> Data {
        let input = HumeAI.APISpecification.RequestBodies.TTSInput(
            text: text,
            voiceId: voiceID,
            speed: speed,
            stability: stability,
            similarityBoost: similarityBoost,
            styleExaggeration: styleExaggeration
        )
        
        let stream = try await run(\.generateSpeechStream, with: input)
        
        var request = URLRequest(url: stream.streamURL)
        
        let (audioData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw HumeAI.APIError.audioDataError
        }
        
        guard !audioData.isEmpty else {
            throw HumeAI.APIError.audioDataError
        }
        
        return audioData
    }
}

// MARK: - Conformances

extension HumeAI.Client: _MIService {
    public convenience init(
        account: (any CoreMI._ServiceAccountProtocol)?
    ) async throws {
        let account: any CoreMI._ServiceAccountProtocol = try account.unwrap()
        let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier = try account.serviceVendorIdentifier.unwrap()
        
        guard serviceVendorIdentifier == CoreMI._ServiceVendorIdentifier._HumeAI else {
            throw CoreMI._ServiceClientError.incompatibleVendor(serviceVendorIdentifier)
        }
        
        guard let credential = try account.credential as? CoreMI._ServiceCredentialTypes.APIKeyCredential else {
            throw CoreMI._ServiceClientError.invalidCredential(try account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
