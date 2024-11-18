//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import NetworkKit
import Foundation
import SwiftAPI
import Merge
import FoundationX
import Swallow

extension ElevenLabs {
    @RuntimeDiscoverable
    public final class Client: SwiftAPI.Client, ObservableObject {
        public typealias API = ElevenLabs.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(configuration: API.Configuration) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(apiKey: String?) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension ElevenLabs.APISpecification {
    
    enum RequestBodies {
        public struct SpeechRequest: Codable, Hashable, Equatable {
            public let text: String
            public let voiceSettings: ElevenLabs.VoiceSettings
            public let model: ElevenLabs.Model
            
            private enum CodingKeys: String, CodingKey {
                case text
                case voiceSettings = "voice_settings"
                case model = "model_id"
            }
            
            public init(
                text: String,
                voiceSettings: ElevenLabs.VoiceSettings,
                model: ElevenLabs.Model
            ) {
                self.text = text
                self.voiceSettings = voiceSettings
                self.model = model
            }
        }
        
        public struct TextToSpeechInput: Codable, Hashable {
            public let voiceId: String
            public let requestBody: SpeechRequest
            
            public init(voiceId: String, requestBody: SpeechRequest) {
                self.voiceId = voiceId
                self.requestBody = requestBody
            }
        }
        
        public struct SpeechToSpeechInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible, Equatable {
            public let voiceId: String
            public let audioURL: URL
            public let model: ElevenLabs.Model
            public let voiceSettings: ElevenLabs.VoiceSettings
            
            public init(
                voiceId: String,
                audioURL: URL,
                model: ElevenLabs.Model,
                voiceSettings: ElevenLabs.VoiceSettings
            ) {
                self.voiceId = voiceId
                self.audioURL = audioURL
                self.model = model
                self.voiceSettings = voiceSettings
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result = HTTPRequest.Multipart.Content()
                
                result.append(
                    .text(
                        named: "model_id",
                        value: model.rawValue
                    )
                )
                
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                if let voiceSettingsData = try? encoder.encode(voiceSettings),
                   let voiceSettingsString = String(
                    data: voiceSettingsData,
                    encoding: .utf8
                   ) {
                    result.append(
                        .text(
                            named: "voice_settings",
                            value: voiceSettingsString
                        )
                    )
                }
                
                if let fileData = try? Data(contentsOf: audioURL) {
                    result.append(
                        .file(
                            named: "audio",
                            data: fileData,
                            filename: audioURL.lastPathComponent,
                            contentType: .mpeg
                        )
                    )
                }
                
                return result
            }
        }
        
        public struct AddVoiceInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible, Equatable {
            public let name: String
            public let description: String
            public let fileURL: URL
            
            public init(
                name: String,
                description: String,
                fileURL: URL
            ) {
                self.name = name
                self.description = description
                self.fileURL = fileURL
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result = HTTPRequest.Multipart.Content()
                
                result.append(
                    .text(
                        named: "name",
                        value: name
                    )
                )
                
                result.append(
                    .text(
                        named: "description",
                        value: description
                    )
                )
                
                result.append(
                    .text(
                        named: "labels",
                        value: ""
                    )
                )
                
                if let fileData = try? Data(contentsOf: fileURL) {
                    result.append(
                        .file(
                            named: "files",
                            data: fileData,
                            filename: fileURL.lastPathComponent,
                            contentType: .wav
                        )
                    )
                }
                
                return result
            }
        }
        
        public struct EditVoiceInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible, Equatable {
            public let voiceId: String
            public let name: String
            public let description: String?
            public let fileURL: URL?
            public let removeBackgroundNoise: Bool
            
            public init(
                voiceId: String,
                name: String,
                description: String? = nil,
                fileURL: URL? = nil,
                removeBackgroundNoise: Bool = false
            ) {
                self.voiceId = voiceId
                self.name = name
                self.description = description
                self.fileURL = fileURL
                self.removeBackgroundNoise = removeBackgroundNoise
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result = HTTPRequest.Multipart.Content()
                
                result.append(.text(named: "name", value: name))
                
                if let description = description {
                    result.append(.text(named: "description", value: description))
                }
                
                result.append(.text(named: "remove_background_noise", value: removeBackgroundNoise ? "true" : "false"))
                
                if let fileURL = fileURL,
                   let fileData = try? Data(contentsOf: fileURL) {
                    result.append(
                        .file(
                            named: "files",
                            data: fileData,
                            filename: fileURL.lastPathComponent,
                            contentType: .m4a
                        )
                    )
                }
                
                return result
            }
        }
    }
}

// Client API Methods
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
        fileURL: URL,
        removeBackgroundNoise: Bool = false
    ) async throws -> Bool {
        let input = ElevenLabs.APISpecification.RequestBodies.EditVoiceInput(
            voiceId: voice.rawValue,
            name: name,
            description: description,
            fileURL: fileURL,
            removeBackgroundNoise: removeBackgroundNoise
        )
        
        return try await run(\.editVoice, with: input)
    }
    
    public func delete(
        voice: ElevenLabs.Voice.ID
    ) async throws {
        try await run(\.deleteVoice, with: voice.rawValue)
    }
}
