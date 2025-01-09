//
//  ElevenLabs.RequestTypes.swift
//  AI
//
//  Created by Jared Davidson on 11/18/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension ElevenLabs.APISpecification {
    
    enum RequestBodies {
        public struct SpeechRequest: Codable, Hashable, Equatable {
            public let text: String
            public let languageCode: String?
            public let voiceSettings: ElevenLabs.VoiceSettings
            public let model: ElevenLabs.Model
            
            private enum CodingKeys: String, CodingKey {
                case text
                case voiceSettings = "voice_settings"
                case model = "model_id"
                case languageCode = "language_code"
            }
            
            public init(
                text: String,
                languageCode: String?,
                voiceSettings: ElevenLabs.VoiceSettings,
                model: ElevenLabs.Model
            ) {
                self.text = text
                self.languageCode = languageCode
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
            public let languageCode: String?
            public let model: ElevenLabs.Model
            public let voiceSettings: ElevenLabs.VoiceSettings
            
            public init(
                voiceId: String,
                audioURL: URL,
                languageCode: String?,
                model: ElevenLabs.Model,
                voiceSettings: ElevenLabs.VoiceSettings
            ) {
                self.voiceId = voiceId
                self.audioURL = audioURL
                self.languageCode = languageCode
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
                
                if let languageCode {
                    result.append(
                        .text(
                            named: "language_code",
                            value: languageCode
                        )
                    )
                }
                
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
        
        public struct DubbingRequest: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible {
            public let name: String?
            public let sourceURL: URL?
            public let sourceLang: String?
            public let targetLang: String
            public let numSpeakers: Int?
            public let watermark: Bool?
            public let startTime: Int?
            public let endTime: Int?
            public let highestResolution: Bool?
            public let dropBackgroundAudio: Bool?
            public let useProfanityFilter: Bool?
            public let fileData: Data?
            
            public init(
                name: String? = nil,
                sourceURL: URL? = nil,
                sourceLang: String? = nil,
                targetLang: String,
                numSpeakers: Int? = nil,
                watermark: Bool? = nil,
                startTime: Int? = nil,
                endTime: Int? = nil,
                highestResolution: Bool? = nil,
                dropBackgroundAudio: Bool? = nil,
                useProfanityFilter: Bool? = nil,
                fileData: Data? = nil
            ) {
                self.name = name
                self.sourceURL = sourceURL
                self.sourceLang = sourceLang
                self.targetLang = targetLang
                self.numSpeakers = numSpeakers
                self.watermark = watermark
                self.startTime = startTime
                self.endTime = endTime
                self.highestResolution = highestResolution
                self.dropBackgroundAudio = dropBackgroundAudio
                self.useProfanityFilter = useProfanityFilter
                self.fileData = fileData
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result = HTTPRequest.Multipart.Content()
                
                if let name {
                    result.append(.text(named: "name", value: name))
                }
                
                if let sourceURL {
                    result.append(.text(named: "source_url", value: sourceURL.absoluteString))
                }
                
                if let sourceLang {
                    result.append(.text(named: "source_lang", value: sourceLang))
                }
                
                result.append(.text(named: "target_lang", value: targetLang))
                
                if let numSpeakers {
                    result.append(.text(named: "num_speakers", value: String(numSpeakers)))
                }
                
                if let watermark {
                    result.append(.text(named: "watermark", value: String(watermark)))
                }
                
                if let startTime {
                    result.append(.text(named: "start_time", value: String(startTime)))
                }
                
                if let endTime {
                    result.append(.text(named: "end_time", value: String(endTime)))
                }
                
                if let highestResolution {
                    result.append(.text(named: "highest_resolution", value: String(highestResolution)))
                }
                
                if let dropBackgroundAudio {
                    result.append(.text(named: "drop_background_audio", value: String(dropBackgroundAudio)))
                }
                
                if let useProfanityFilter {
                    result.append(.text(named: "use_profanity_filter", value: String(useProfanityFilter)))
                }
                
                if let fileData {
                    result.append(
                        .file(
                            named: "file",
                            data: fileData,
                            filename: "input.mp4",
                            contentType: .mp4
                        )
                    )
                }
                
                return result
            }
        }
        public struct DubbingInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible {
            public let voiceId: String
            public let audioURL: URL
            public let languageCode: String
            public let model: ElevenLabs.Model
            public let voiceSettings: ElevenLabs.VoiceSettings
            
            public init(
                voiceId: String,
                audioURL: URL,
                languageCode: String,
                model: ElevenLabs.Model,
                voiceSettings: ElevenLabs.VoiceSettings
            ) {
                self.voiceId = voiceId
                self.audioURL = audioURL
                self.languageCode = languageCode
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
                
                result.append(
                    .text(
                        named: "language_code",
                        value: languageCode
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
    }
}
