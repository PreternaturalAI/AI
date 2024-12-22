//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation
import NetworkKit
import SwiftAPI

extension _Gemini.APISpecification {
    public enum RequestBodies {
        public struct CompleteUploadInput: Codable {
            public let uploadURL: URL
            public let fileData: Data
            public let offset: Int
            
            public init(
                uploadURL: URL,
                fileData: Data,
                offset: Int = 0
            ) {
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
            public let generationConfig: _Gemini.GenerationConfiguration?
            public let tools: [_Gemini.Tool]?
            public let toolConfiguration: _Gemini.ToolConfiguration?
            public let systemInstruction: Content?
            
            private enum CodingKeys: String, CodingKey {
                case contents
                case cachedContent
                case generationConfig
                case tools
                case toolConfiguration = "tool_config"
                case systemInstruction = "system_instruction"
            }
            
            public init(
                contents: [Content],
                cachedContent: String? = nil,
                generationConfig: _Gemini.GenerationConfiguration? = nil,
                tools: [_Gemini.Tool]? = nil,
                toolConfiguration: _Gemini.ToolConfiguration? = nil,
                systemInstruction: Content? = nil
            ) {
                self.contents = contents
                self.cachedContent = cachedContent
                self.generationConfig = generationConfig
                self.tools = tools
                self.toolConfiguration = toolConfiguration
                self.systemInstruction = systemInstruction
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
        
        public struct FileUploadInput: Codable, HTTPRequest.Multipart.ContentConvertible {
            public let fileData: Data
            public let mimeType: String
            public let displayName: String
            
            public init(
                fileData: Data,
                mimeType: String,
                displayName: String
            ) {
                self.fileData = fileData
                self.mimeType = mimeType
                self.displayName = displayName
            }
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result = HTTPRequest.Multipart.Content()
                                
                // TODO: - Add this to `HTTPMediaType` @jared @vmanot
                let fileExtension: String = {
                    guard let subtype = mimeType.split(separator: "/").last else {
                        return "bin"
                    }
                    
                    switch subtype {
                        case "quicktime":
                            return "mov"
                        case "x-m4a":
                            return "m4a"
                        case "mp4":
                            return "mp4"
                        case "jpeg", "jpg":
                            return "jpg"
                        case "png":
                            return "png"
                        case "gif":
                            return "gif"
                        case "webp":
                            return "webp"
                        case "pdf":
                            return "pdf"
                        default:
                            return String(subtype)
                    }
                }()
                
                result.append(
                    .file(
                        named: "file",
                        data: fileData,
                        filename: "\(displayName).\(fileExtension)",
                        contentType: .init(rawValue: mimeType)
                    )
                )
                
                return result
            }
        }
        
        public struct DeleteFileInput: Codable {
            public let fileURL: URL
            
            public init(
                fileURL: URL
            ) {
                self.fileURL = fileURL
            }
        }
        
        public struct FileStatusInput: Codable {
            public let name: _Gemini.File.Name
        }
        
        public struct FileListInput: Codable {
            // Maximum number of Files to return per page. If unspecified, defaults to 10. Maximum pageSize is 100.
            public let pageSize: Int?
            // A page token from a previous files.list call.
            public let pageToken: String?
        }
        
        // Fine Tuning
        
        public struct CreateTunedModel: Codable {
            public let requestBody: _Gemini.TuningConfig
            
            public init(
                requestBody: _Gemini.TuningConfig
            ) {
                self.requestBody = requestBody
            }
        }
        
        public struct GetOperation: Codable {
            public let operationName: String
            
            public init(
                operationName: String
            ) {
                self.operationName = operationName
            }
        }
        
        public struct GetTunedModel: Codable {
            public let modelName: String
            
            public init(
                modelName: String
            ) {
                self.modelName = modelName
            }
        }
        
        public struct EmbeddingInput: Codable {
            public let model: String
            public let content: Content
            
            public init(
                model: _Gemini.Model,
                content: Content
            ) {
                self.model = model.rawValue
                self.content = content
            }
        }
    }
}
