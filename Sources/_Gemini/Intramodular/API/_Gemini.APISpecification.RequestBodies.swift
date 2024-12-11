//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import SwiftAPI
import Foundation

extension _Gemini.APISpecification {
    public enum RequestBodies {
        public struct GenerateContentInput: Codable {
            public let model: String
            public let requestBody: SpeechRequest
            
            public init(model: String, requestBody: SpeechRequest) {
                self.model = model
                self.requestBody = requestBody
            }
        }
        
        public struct SpeechRequest: Codable {
            public let contents: [Content]
            public let cachedContent: String?
            public let generationConfig: GenerationConfig?
            public let safetySettings: [_Gemini.SafetySetting]?
            public let systemInstruction: _Gemini.SystemInstruction?
            public let tools: [_Gemini.Tool]?
            public let toolConfig: _Gemini.ToolConfig?
            
            public init(
                contents: [Content],
                cachedContent: String? = nil,
                generationConfig: GenerationConfig? = nil,
                safetySettings: [_Gemini.SafetySetting]? = nil,
                systemInstruction: _Gemini.SystemInstruction? = nil,
                tools: [_Gemini.Tool]? = nil,
                toolConfig: _Gemini.ToolConfig? = nil
            ) {
                self.contents = contents
                self.cachedContent = cachedContent
                self.generationConfig = generationConfig
                self.safetySettings = safetySettings
                self.systemInstruction = systemInstruction
                self.tools = tools
                self.toolConfig = toolConfig
            }
        }
        
        public struct Content: Codable {
            public let role: String?
            public let parts: [Part]
            
            public init(role: String? = nil, parts: [Part]) {
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
                
                private enum InlineDataNestedKeys: String, CodingKey {
                    case data
                    case mimeType
                }
                
                private enum FileDataNestedKeys: String, CodingKey {
                    case fileUri
                    case mimeType
                }
                
                public init(from decoder: Decoder) throws {
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    
                    if let text = try? container.decode(String.self, forKey: .text) {
                        self = .text(text)
                        return
                    }
                    
                    if let inlineContainer = try? container.nestedContainer(keyedBy: InlineDataNestedKeys.self, forKey: .inlineData) {
                        let base64Data = try inlineContainer.decode(String.self, forKey: .data)
                        let mimeType = try inlineContainer.decode(String.self, forKey: .mimeType)
                        if let data = Data(base64Encoded: base64Data) {
                            self = .inline(data: data, mimeType: mimeType)
                            return
                        }
                    }
                    
                    if let fileContainer = try? container.nestedContainer(keyedBy: FileDataNestedKeys.self, forKey: .fileData) {
                        let url = try fileContainer.decode(URL.self, forKey: .fileUri)
                        let mimeType = try fileContainer.decode(String.self, forKey: .mimeType)
                        self = .file(url: url, mimeType: mimeType)
                        return
                    }
                    
                    throw DecodingError.dataCorrupted(
                        DecodingError.Context(
                            codingPath: decoder.codingPath,
                            debugDescription: "Unable to decode Part"
                        )
                    )
                }
                
                public func encode(to encoder: Encoder) throws {
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    switch self {
                    case .text(let txt):
                        try container.encode(txt, forKey: .text)
                    case .inline(data: let data, mimeType: let mimeType):
                        var nestedContainer = container.nestedContainer(
                            keyedBy: InlineDataNestedKeys.self,
                            forKey: .inlineData
                        )
                        try nestedContainer.encode(data.base64EncodedString(), forKey: .data)
                        try nestedContainer.encode(mimeType, forKey: .mimeType)
                    case .file(url: let url, mimeType: let mimeType):
                        var nestedContainer = container.nestedContainer(
                            keyedBy: FileDataNestedKeys.self,
                            forKey: .fileData
                        )
                        try nestedContainer.encode(url, forKey: .fileUri)
                        try nestedContainer.encode(mimeType, forKey: .mimeType)
                    }
                }
            }
        }
        
        public struct GenerationConfig: Codable {
            public let maxTokens: Int?
            public let temperature: Double?
            public let topP: Double?
            public let topK: Int?
            public let presencePenalty: Double?
            public let frequencyPenalty: Double?
            
            public init(
                maxTokens: Int? = nil,
                temperature: Double? = nil,
                topP: Double? = nil,
                topK: Int? = nil,
                presencePenalty: Double? = nil,
                frequencyPenalty: Double? = nil
            ) {
                self.maxTokens = maxTokens
                self.temperature = temperature
                self.topP = topP
                self.topK = topK
                self.presencePenalty = presencePenalty
                self.frequencyPenalty = frequencyPenalty
            }
        }
        
        public struct FileUploadInput: Codable, HTTPRequest.Multipart.ContentConvertible {
            public let fileData: Data
            public let mimeType: String
            
            public init(fileData: Data, mimeType: String) {
                self.fileData = fileData
                self.mimeType = mimeType
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result = HTTPRequest.Multipart.Content()
                
                // Add the JSON part
                let jsonBody = ["file": ["mimeType": self.mimeType]]
                let jsonData = try JSONSerialization.data(withJSONObject: jsonBody)
                result.append(
                    .text(
                        named: "metadata",
                        value: String(data: jsonData, encoding: .utf8) ?? ""
                    )
                )
                
                // Add the file part
                result.append(
                    .file(
                        named: "file",
                        data: fileData,
                        filename: "file",
                        contentType: .init(rawValue: mimeType)
                    )
                )
                
                return result
            }
        }
        
        public struct DeleteFileInput: Codable {
            public let fileURL: URL
            
            public init(fileURL: URL) {
                self.fileURL = fileURL
            }
        }
    }
}
