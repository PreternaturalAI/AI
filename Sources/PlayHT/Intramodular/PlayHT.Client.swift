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
    
    public func getAllAvailableVoices() async throws -> [PlayHT.Voice] {
        async let htVoices = playHTAvailableVoices()
        async let clonedVoices = clonedVoices()
        
        let (available, cloned) = try await (htVoices, clonedVoices)
        return available + cloned
    }
    
    public func playHTAvailableVoices() async throws -> [PlayHT.Voice] {
        try await run(\.listVoices).voices
    }
    
    public func clonedVoices() async throws -> [PlayHT.Voice] {
        try await run(\.listClonedVoices).voices
    }
    
    public func streamTextToSpeech(
        text: String,
        voice: String,
        settings: PlayHT.VoiceSettings,
        outputSettings: PlayHT.OutputSettings = .default,
        model: PlayHT.Model
    ) async throws -> Data {
        // Construct the input for the API
        let input = PlayHT.APISpecification.RequestBodies.TextToSpeechInput(
            text: text,
            voice: voice,
            voiceEngine: model,
            quality: outputSettings.quality.rawValue,
            outputFormat: outputSettings.format.rawValue
        )
        
        // Fetch the initial JSON response
        let responseData = try await run(\.streamTextToSpeech, with: input)
        
        // Decode the response to extract the audio URL
        let audioResponse = try JSONDecoder().decode(PlayHT.Client.AudioResponse.self, from: responseData)
        
        guard let audioUrl = URL(string: audioResponse.href) else {
            throw PlayHTError.invalidURL
        }
        
        #warning("This should be cleaned up @jared")
        var request = URLRequest(url: audioUrl)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(interface.configuration.userId ?? "", forHTTPHeaderField: "X-USER-ID")
        request.addValue(interface.configuration.apiKey ?? "", forHTTPHeaderField: "AUTHORIZATION")
        
        let (audioData, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw PlayHTError.audioFetchFailed
        }
        
        guard !audioData.isEmpty else {
            throw PlayHTError.audioFetchFailed
        }
        
        return audioData
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
        try await run(\.deleteClonedVoice, with: .init(voiceID: voice.rawValue))
    }
}

extension PlayHT.Client {
    enum PlayHTError: LocalizedError {
        case invalidURL
        case audioFetchFailed
        
        var errorDescription: String? {
            switch self {
                case .invalidURL:
                    return "Invalid audio URL received from PlayHT"
                case .audioFetchFailed:
                    return "Failed to fetch audio data from PlayHT"
            }
        }
    }
}
extension PlayHT.Client {
    public struct AudioResponse: Codable {
        public let description: String
        public let method: String
        public let href: String
        public let contentType: String
        public let rel: String
    }
}
