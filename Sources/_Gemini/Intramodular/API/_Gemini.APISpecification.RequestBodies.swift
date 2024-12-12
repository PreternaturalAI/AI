//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import SwiftAPI
import Foundation

extension _Gemini.APISpecification {
    public enum RequestBodies {
        public struct CompleteUploadInput: Codable {
            public let uploadURL: URL
            public let fileData: Data
            public let offset: Int
            
            public init(uploadURL: URL, fileData: Data, offset: Int = 0) {
                self.uploadURL = uploadURL
                self.fileData = fileData
                self.offset = offset
            }
        }
        
        public struct GenerateContentInput: Codable {
            public let model: String
            public let requestBody: ContentBody
            
            public init(
                model: _Gemini.Model,
                requestBody: ContentBody
            ) {
                self.model = model.rawValue
                self.requestBody = requestBody
            }
        }
        
        public struct ContentBody: Codable {
            public let contents: [Content]
            public let cachedContent: String?
            public let generationConfig: GenerationConfig?
            
            public init(
                contents: [Content],
                cachedContent: String? = nil,
                generationConfig: GenerationConfig? = nil
            ) {
                self.contents = contents
                self.cachedContent = cachedContent
                self.generationConfig = generationConfig
            }
        }
        
        public struct Content: Codable {
            public let role: String
            public let parts: [Part]
            
            public init(role: String, parts: [Part]) {
                self.role = role
                self.parts = parts
            }
            
            public enum Part: Codable {
                case text(String)
                case inline(data: Data, mimeType: String)
                case file(url: URL, mimeType: String)
                
                private enum CodingKeys: String, CodingKey {
                    case text
                    case inlineData
                    case fileData
                }
                
                private enum FileDataKeys: String, CodingKey {
                    case fileUri
                    case mimeType
                }
                
                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    
                    switch self {
                        case .text(let text):
                            try container.encode(text, forKey: .text)
                            
                        case .inline(data: let data, mimeType: let mimeType):
                            var nested = container.nestedContainer(keyedBy: FileDataKeys.self, forKey: .inlineData)
                            try nested.encode(data.base64EncodedString(), forKey: .fileUri)
                            try nested.encode(mimeType, forKey: .mimeType)
                            
                        case .file(url: let url, mimeType: let mimeType):
                            var nested = container.nestedContainer(keyedBy: FileDataKeys.self, forKey: .fileData)
                            try nested.encode(url.absoluteString, forKey: .fileUri)
                            try nested.encode(mimeType, forKey: .mimeType)
                    }
                }
                
                public init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    
                    if let text = try? container.decode(String.self, forKey: .text) {
                        self = .text(text)
                        return
                    }
                    
                    if let nested = try? container.nestedContainer(keyedBy: FileDataKeys.self, forKey: .fileData) {
                        let uri = try nested.decode(String.self, forKey: .fileUri)
                        let mimeType = try nested.decode(String.self, forKey: .mimeType)
                        if let url = URL(string: uri) {
                            self = .file(url: url, mimeType: mimeType)
                            return
                        }
                    }
                    
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Could not decode Part"
                        )
                    )
                }
            }
        }
        
        public struct GenerationConfig: Codable {
            public let maxOutputTokens: Int?
            public let temperature: Double?
            public let topP: Double?
            public let topK: Int?
            public let presencePenalty: Double?
            public let frequencyPenalty: Double?
            public let responseMimeType: String?
            
            public init(
                maxOutputTokens: Int? = nil,
                temperature: Double? = nil,
                topP: Double? = nil,
                topK: Int? = nil,
                presencePenalty: Double? = nil,
                frequencyPenalty: Double? = nil,
                responseMimeType: String? = nil
            ) {
                self.maxOutputTokens = maxOutputTokens
                self.temperature = temperature
                self.topP = topP
                self.topK = topK
                self.presencePenalty = presencePenalty
                self.frequencyPenalty = frequencyPenalty
                self.responseMimeType = responseMimeType
            }
        }
        
        public struct FileUploadInput: Codable, HTTPRequest.Multipart.ContentConvertible {
            public let fileData: Data
            public let mimeType: String
            public let displayName: String
            
            public init(fileData: Data, mimeType: String, displayName: String) {
                self.fileData = fileData
                self.mimeType = mimeType
                self.displayName = displayName
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result = HTTPRequest.Multipart.Content()
                
                // Add metadata as JSON
                let metadata = ["file": ["display_name": displayName]]
                let metadataData = try JSONSerialization.data(withJSONObject: metadata)

                let fileExtension = mimeType.split(separator: "/").last == "quicktime" ? "mov" :
                                              String(mimeType.split(separator: "/").last ?? "bin")
                
                result.append(
                    .file(
                        named: "file",
                        data: fileData,
                        filename: "\(displayName).\(fileExtension)",
                        contentType: .init(rawValue: mimeType)
                    )
                )
                
                
                print("BODY", result)
                return result
            }
        }
        
        public struct DeleteFileInput: Codable {
            public let fileURL: URL
            
            public init(fileURL: URL) {
                self.fileURL = fileURL
            }
        }
        
        public struct FileStatusInput: Codable {
            public let name: String
        }
    }
}
