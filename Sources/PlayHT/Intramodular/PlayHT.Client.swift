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
        
        public convenience init(apiKey: String) {
            self.init(configuration: .init(apiKey: apiKey))
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
    
    public func clonedVoices() async throws -> [PlayHT.Voice] {
        try await run(\.listClonedVoices).voices
    }
    
    public func generateSpeech(
        text: String,
        voice: PlayHT.Voice,
        settings: PlayHT.VoiceSettings,
        outputSettings: PlayHT.OutputSettings = .default
    ) async throws -> String? {
        let input = PlayHT.APISpecification.RequestBodies.TextToSpeechInput(
            text: text,
            voice: voice.id.rawValue,
            voiceEngine: voice.voiceEngine,
            quality: outputSettings.quality.rawValue,
            outputFormat: outputSettings.format.rawValue,
            speed: settings.speed,
            sampleRate: outputSettings.sampleRate,
            temperature: settings.temperature,
            voiceGuidance: settings.voiceGuidance,
            styleGuidance: settings.styleGuidance,
            textGuidance: settings.textGuidance,
            language: voice.language
        )
        
        let response = try await run(\.textToSpeech, with: input)
        return response.audioUrl
    }
    
    public func streamSpeech(
        text: String,
        voice: PlayHT.Voice,
        settings: PlayHT.VoiceSettings,
        outputSettings: PlayHT.OutputSettings = .default
    ) async throws -> Data {
        let input = PlayHT.APISpecification.RequestBodies.TextToSpeechInput(
            text: text,
            voice: voice.id.rawValue,
            voiceEngine: voice.voiceEngine,
            quality: outputSettings.quality.rawValue,
            outputFormat: outputSettings.format.rawValue,
            speed: settings.speed,
            sampleRate: outputSettings.sampleRate,
            temperature: settings.temperature,
            voiceGuidance: settings.voiceGuidance,
            styleGuidance: settings.styleGuidance,
            textGuidance: settings.textGuidance,
            language: voice.language
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
    
    private func findVoice(id: String) async throws -> PlayHT.Voice? {
        let allVoices = try await availableVoices()
        let clonedVoices = try await clonedVoices()
        return (allVoices + clonedVoices).first { $0.id.rawValue == id }
    }
}
