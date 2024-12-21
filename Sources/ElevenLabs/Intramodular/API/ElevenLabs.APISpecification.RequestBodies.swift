//
// Copyright (c) Preternatural AI, Inc.
//

import Merge
import NetworkKit
import SwiftAPI

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
                
                if let fileData = try? Data(contentsOf: fileURL) {
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
        
        public struct EditVoiceInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible, Equatable {
            public let voiceId: String
            public let name: String
            public let description: String?
            public let fileURL: URL?
            
            public init(
                voiceId: String,
                name: String,
                description: String? = nil,
                fileURL: URL? = nil
            ) {
                self.voiceId = voiceId
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
                
                if let description = description {
                    result.append(
                        .text(
                            named: "description",
                            value: description
                        )
                    )
                }
                
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
