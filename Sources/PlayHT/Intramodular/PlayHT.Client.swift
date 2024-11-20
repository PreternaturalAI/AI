//
//  PlayHT.Client.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension PlayHT {
    @RuntimeDiscoverable
    public final class Client: SwiftAPI.Client, ObservableObject {
        public typealias API = PlayHT.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(configuration: API.Configuration) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(apiKey: String?, userId: String?) {
            self.init(configuration: .init(apiKey: apiKey, userId: userId))
        }
    }
}

extension PlayHT.Client: _MIService {
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

extension PlayHT.Client {
    public func availableVoices() async throws -> [PlayHT.Voice] {
        try await run(\.listVoices).voices
    }
    
    public func generateSpeech(
        text: String,
        voiceId: String,
        quality: String = "medium",
        outputFormat: String = "mp3",
        speed: Double? = nil,
        sampleRate: Int? = nil
    ) async throws -> String? {
        let input = PlayHT.APISpecification.RequestBodies.TextToSpeechInput(
            text: text,
            voiceId: voiceId,
            quality: quality,
            outputFormat: outputFormat,
            speed: speed,
            sampleRate: sampleRate
        )
        
        let response = try await run(\.textToSpeech, with: input)
        return response.audioUrl
    }
    
    public func streamSpeech(
        text: String,
        voiceId: String,
        quality: String = "medium",
        outputFormat: String = "mp3",
        speed: Double? = nil,
        sampleRate: Int? = nil
    ) async throws -> Data {
        let input = PlayHT.APISpecification.RequestBodies.TextToSpeechInput(
            text: text,
            voiceId: voiceId,
            quality: quality,
            outputFormat: outputFormat,
            speed: speed,
            sampleRate: sampleRate
        )
        
        return try await run(\.streamTextToSpeech, with: input)
    }
    
    public func cloneVoice(
        name: String,
        description: String? = nil,
        fileURLs: [URL]
    ) async throws -> (id: String, name: String, status: String) {
        let input = PlayHT.APISpecification.RequestBodies.CloneVoiceInput(
            name: name,
            description: description,
            fileURLs: fileURLs
        )
        
        let response = try await run(\.cloneVoice, with: input)
        return (response.id, response.name, response.status)
    }
    
    public func deleteClonedVoice(
        id: String
    ) async throws {
        try await run(\.deleteClonedVoice, with: id)
    }
}
