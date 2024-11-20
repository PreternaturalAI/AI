//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension ElevenLabs {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            _MIServiceTypeIdentifier._ElevenLabs
        }
        
        public typealias API = ElevenLabs.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        
        public required init(configuration: API.Configuration) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
        }
        
        public convenience init(apiKey: String?) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension ElevenLabs.Client: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account: any _MIServiceAccount = try account.unwrap()
        let serviceIdentifier: _MIServiceTypeIdentifier = account.serviceIdentifier
        
        guard serviceIdentifier == _MIServiceTypeIdentifier._ElevenLabs else {
            throw _MIServiceError.serviceTypeIncompatible(serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}

extension ElevenLabs.Client {
    public func availableVoices() async throws -> [ElevenLabs.Voice] {
        try await run(\.listVoices).voices
    }
    
    @discardableResult
    public func speech(
        for text: String,
        voiceID: String,
        voiceSettings: ElevenLabs.VoiceSettings,
        model: ElevenLabs.Model
    ) async throws -> Data {
        let requestBody = ElevenLabs.APISpecification.RequestBodies.SpeechRequest(
            text: text,
            voiceSettings: voiceSettings,
            model: model
        )
        
        return try await run(\.textToSpeech, with: .init(voiceId: voiceID, requestBody: requestBody))
    }
    
    public func speechToSpeech(
        inputAudioURL: URL,
        voiceID: String,
        voiceSettings: ElevenLabs.VoiceSettings,
        model: ElevenLabs.Model
    ) async throws -> Data {
        let input = ElevenLabs.APISpecification.RequestBodies.SpeechToSpeechInput(
            voiceId: voiceID,
            audioURL: inputAudioURL,
            model: model,
            voiceSettings: voiceSettings
        )
        
        return try await run(\.speechToSpeech, with: input)
    }
    
    public func upload(
        voiceWithName name: String,
        description: String,
        fileURL: URL
    ) async throws -> ElevenLabs.Voice.ID {
        let input = ElevenLabs.APISpecification.RequestBodies.AddVoiceInput(
            name: name,
            description: description,
            fileURL: fileURL
        )
        
        let response = try await run(\.addVoice, with: input)
        return .init(rawValue: response.voiceId)
    }
    
    public func edit(
        voice: ElevenLabs.Voice.ID,
        name: String,
        description: String,
        fileURL: URL?
    ) async throws -> Bool {
        let input = ElevenLabs.APISpecification.RequestBodies.EditVoiceInput(
            voiceId: voice.rawValue,
            name: name,
            description: description,
            fileURL: fileURL
        )
        
        return try await run(\.editVoice, with: input)
    }
    
    public func delete(
        voice: ElevenLabs.Voice.ID
    ) async throws {
        try await run(\.deleteVoice, with: voice.rawValue)
    }
}
