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
                
                public struct Content: Decodable {
                    public let parts: [Part]?
                    public let role: String?
                    
                    public enum Part: Decodable {
                        case text(String)
                        
                        private enum CodingKeys: String, CodingKey {
                            case text
                        }
                        
                        public init(from decoder: Decoder) throws {
                            let container = try decoder.container(keyedBy: CodingKeys.self)
                            self = .text(try container.decode(String.self, forKey: .text))
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
    }
}
