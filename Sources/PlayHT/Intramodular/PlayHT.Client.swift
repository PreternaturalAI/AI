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
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            _MIServiceTypeIdentifier._PlayHT
        }
        
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
        
        public convenience init(apiKey: String, userID: String) {
            self.init(configuration: .init(apiKey: apiKey, userId: userID))
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
        
        guard let credential = account.credential as? _MIServiceUserIDAndAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey, userID: credential.userID)
    }
}

extension PlayHT.Client {
    public func playHTAvailableVoices() async throws -> [PlayHT.Voice] {
        try await run(\.listVoices).voices
    }
    
    public func clonedVoices() async throws -> [PlayHT.Voice] {
        try await run(\.listClonedVoices).voices
    }
    
    public func generateSpeech(
        text: String,
        voice: String,
        settings: PlayHT.VoiceSettings,
        outputSettings: PlayHT.OutputSettings = .default,
        model: PlayHT.Model
    ) async throws -> Data {
        let input = PlayHT.APISpecification.RequestBodies.TextToSpeechInput(
            text: text,
            voice: voice,
            voiceEngine: model,
            quality: outputSettings.quality.rawValue,
            outputFormat: outputSettings.format.rawValue
        )
        
        let response = try await run(\.streamTextToSpeech, with: input)
        print(response)
        return response
    }
    
    public func streamSpeech(
        text: String,
        voice: String,
        settings: PlayHT.VoiceSettings,
        outputSettings: PlayHT.OutputSettings = .default,
        model: PlayHT.Model
    ) async throws -> Data {
        let input = PlayHT.APISpecification.RequestBodies.TextToSpeechInput(
            text: text,
            voice: voice,
            voiceEngine: model,
            quality: outputSettings.quality.rawValue,
            outputFormat: outputSettings.format.rawValue
        )
        
        return try await run(\.streamTextToSpeech, with: input)
    }
    
    public func instantCloneVoice(
        sampleFileURL: String,
        name: String
    ) async throws -> PlayHT.Voice.ID {
        let input = PlayHT.APISpecification.RequestBodies.InstantCloneVoiceInput(
            sampleFileURL: sampleFileURL,
            voiceName: name
        )
        
        let response = try await run(\.instantCloneVoice, with: input)
        return .init(rawValue: response.id)
    }
    
    public func deleteClonedVoice(
        voice: PlayHT.Voice.ID
    ) async throws {
        try await run(\.deleteClonedVoice, with: voice.rawValue)
    }
}
