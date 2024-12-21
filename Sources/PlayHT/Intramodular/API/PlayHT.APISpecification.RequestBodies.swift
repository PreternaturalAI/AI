//
// Copyright (c) Preternatural AI, Inc.
//

import Merge
import NetworkKit
import SwiftAPI

extension PlayHT.APISpecification {
    enum RequestBodies {
        public struct TextToSpeechInput: Codable, Hashable {
            public let text: String
            public let voice: String
            public let voiceEngine: PlayHT.Model
            public let quality: String
            public let outputFormat: String
            
            //            public let speed: Double?
            //            public let sampleRate: Int?
            //            public let seed: Int?
            //            public let temperature: Double?
            //            public let emotion: String?
            //            public let voiceGuidance: Double?
            //            public let styleGuidance: Double?
            //            public let textGuidance: Double?
            //            public let language: String?
            //
            private enum CodingKeys: String, CodingKey {
                case text, voice, quality
                case voiceEngine = "voice_engine"
                case outputFormat = "output_format"
                //                case speed
                //                case sampleRate = "sample_rate"
                //                case seed, temperature, emotion
                //                case voiceGuidance = "voice_guidance"
                //                case styleGuidance = "style_guidance"
                //                case textGuidance = "text_guidance"
                //                case language
            }
            
            public init(
                text: String,
                voice: String,
                voiceEngine: PlayHT.Model = .playHT2,
                quality: String = "medium",
                outputFormat: String = "mp3"
                //                speed: Double? = nil,
                //                sampleRate: Int? = 48000,
                //                seed: Int? = nil,
                //                temperature: Double? = nil,
                //                emotion: String? = nil,
                //                voiceGuidance: Double? = nil,
                //                styleGuidance: Double? = nil,
                //                textGuidance: Double? = nil,
                //                language: String? = nil
            ) {
                self.text = text
                self.voice = voice
                self.voiceEngine = voiceEngine
                self.quality = quality
                self.outputFormat = outputFormat
                //                self.speed = speed
                //                self.sampleRate = sampleRate
                //                self.seed = seed
                //                self.temperature = temperature
                //                self.emotion = emotion
                //                self.voiceGuidance = voiceGuidance
                //                self.styleGuidance = styleGuidance
                //                self.textGuidance = textGuidance
                //                self.language = language
            }
        }
        
        public struct DeleteVoiceInput: Codable, Hashable {
            var voiceID: String
            
            enum CodingKeys: String, CodingKey {
                case voiceID = "voice_id"
            }
        }
        
        public struct InstantCloneVoiceInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible {
            public let sampleFileURL: String
            public let voiceName: String
            
            public init(sampleFileURL: String, voiceName: String) {
                self.sampleFileURL = sampleFileURL
                self.voiceName = voiceName
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result: HTTPRequest.Multipart.Content = .init()
                
                if let url: URL = URL(string: sampleFileURL),
                   let fileData = try? Data(contentsOf: url) {
                    result.append(
                        .file(
                            named: "sample_file",
                            data: fileData,
                            filename: url.lastPathComponent,
                            contentType: .mp4
                        )
                    )
                }
                
                result.append(
                    .text(
                        named: "voice_name",
                        value: voiceName
                    )
                )
                
                return result
            }
        }
        
        public struct InstantCloneVoiceWithURLInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible {
            public let url: String
            public let voiceName: String
            
            public init(
                url: String,
                voiceName: String
            ) {
                self.url = url
                self.voiceName = voiceName
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result: HTTPRequest.Multipart.Content = .init()
                
                result.append(
                    .string(
                        named: "sample_file_url",
                        value: url
                    )
                )
                
                result.append(
                    .text(
                        named: "voice_name",
                        value: voiceName
                    )
                )
                
                return result
            }
        }
    }
}
