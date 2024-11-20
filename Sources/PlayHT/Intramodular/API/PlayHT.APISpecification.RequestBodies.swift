//
//  PlayHT.APISpecification.RequestBodies.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension PlayHT.APISpecification {
    enum RequestBodies {
        public struct TextToSpeechInput: Codable, Hashable {
            public let text: String
            public let voiceId: String
            public let quality: String
            public let outputFormat: String
            public let speed: Double?
            public let sampleRate: Int?
            
            public init(
                text: String,
                voiceId: String,
                quality: String = "medium",
                outputFormat: String = "mp3",
                speed: Double? = nil,
                sampleRate: Int? = nil
            ) {
                self.text = text
                self.voiceId = voiceId
                self.quality = quality
                self.outputFormat = outputFormat
                self.speed = speed
                self.sampleRate = sampleRate
            }
        }
        
        public struct CloneVoiceInput: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible {
            public let name: String
            public let description: String?
            public let fileURLs: [URL]
            
            public init(
                name: String,
                description: String? = nil,
                fileURLs: [URL]
            ) {
                self.name = name
                self.description = description
                self.fileURLs = fileURLs
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
                
                for (index, fileURL) in fileURLs.enumerated() {
                    if let fileData = try? Data(contentsOf: fileURL) {
                        result.append(
                            .file(
                                named: "files[\(index)]",
                                data: fileData,
                                filename: fileURL.lastPathComponent,
                                contentType: .wav
                            )
                        )
                    }
                }
                
                return result
            }
        }
    }
}
