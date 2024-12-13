//
//  _Gemini.APISpecification.ResponseBodies.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Foundation

extension _Gemini.APISpecification {
    public enum ResponseBodies {
        public struct GenerateContent: Decodable {
            public let candidates: [Candidate]?
            public let usageMetadata: UsageMetadata?
            
            public struct Candidate: Decodable {
                public let content: Content?
                public let finishReason: String?
                public let index: Int?
                public let safetyRatings: [SafetyRating]?
                public let functionCall: _Gemini.FunctionCall?
                
                public struct Content: Decodable {
                    public let parts: [Part]?
                    public let role: String?
                    
                    public enum Part: Decodable {
                        case text(String)
                        case functionCall(_Gemini.FunctionCall)
                        
                        private enum CodingKeys: String, CodingKey {
                            case text
                            case functionCall
                        }
                        
                        public init(from decoder: Decoder) throws {
                            let container = try decoder.container(keyedBy: CodingKeys.self)
                            
                            if let text = try? container.decode(String.self, forKey: .text) {
                                self = .text(text)
                                return
                            }
                            
                            if let functionCall = try? container.decode(_Gemini.FunctionCall.self, forKey: .functionCall) {
                                self = .functionCall(functionCall)
                                return
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
                
                public struct SafetyRating: Decodable {
                    public let blocked: Bool?
                    public let category: String?
                    public let probability: String?
                }
            }
            
            public struct UsageMetadata: Decodable {
                public let cachedContentTokenCount: Int?
                public let candidatesTokenCount: Int?
                public let promptTokenCount: Int?
                public let totalTokenCount: Int?
            }
        }
        
        public struct FileUpload: Codable {
            public let file: _Gemini.File
        }
        
        public struct UploadInitiation: Decodable {
            public let uploadURL: URL
        }
    }
}
