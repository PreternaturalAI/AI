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
        }
        
        public struct Candidate: Decodable {
            public let content: Content?
            public let finishReason: String?
            public let index: Int?
            public let safetyRatings: [SafetyRating]?
            public let functionCall: _Gemini.FunctionCall?
            public let groundingMetadata: GroundingMetadata?
            
            public struct Content: Decodable {
                public let parts: [Part]?
                public let role: String?
                
                public enum Part: Decodable {
                    case text(String)
                    case functionCall(_Gemini.FunctionCall)
                    case executableCode(language: String, code: String)
                    case codeExecutionResult(outcome: String, output: String)
                    
                    private enum CodingKeys: String, CodingKey {
                        case text
                        case functionCall
                        case executableCode = "executableCode"
                        case codeExecutionResult = "codeExecutionResult"
                    }
                    
                    private enum ExecutableCodeKeys: String, CodingKey {
                        case language
                        case code
                    }
                    
                    private enum CodeExecutionResultKeys: String, CodingKey {
                        case outcome
                        case output
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
                        
                        if let executableContainer = try? container.nestedContainer(keyedBy: ExecutableCodeKeys.self, forKey: .executableCode) {
                            let language = try executableContainer.decode(String.self, forKey: .language)
                            let code = try executableContainer.decode(String.self, forKey: .code)
                            self = .executableCode(language: language, code: code)
                            return
                        }
                        
                        if let resultContainer = try? container.nestedContainer(keyedBy: CodeExecutionResultKeys.self, forKey: .codeExecutionResult) {
                            let outcome = try resultContainer.decode(String.self, forKey: .outcome)
                            let output = try resultContainer.decode(String.self, forKey: .output)
                            self = .codeExecutionResult(outcome: outcome, output: output)
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
            
            public struct GroundingMetadata: Decodable {
                public let webSearchQueries: [String]?
                public let searchEntryPoint: SearchEntryPoint?
                public let groundingChunks: [WebSource]?
                public let groundingSupports: [GroundingSupport]?
                
                public struct SearchEntryPoint: Decodable {
                    public let renderedContent: String
                }
                
                public struct WebSource: Decodable {
                    public let web: WebInfo
                    
                    public struct WebInfo: Decodable {
                        public let uri: String
                        public let title: String
                    }
                }
                
                public struct GroundingSupport: Decodable {
                    public let segment: Segment
                    public let groundingChunkIndices: [Int]
                    public let confidenceScores: [Double]
                    
                    public struct Segment: Decodable {
                        public let startIndex: Int?
                        public let endIndex: Int
                        public let text: String
                    }
                }
            }
        }
        
        public struct UsageMetadata: Decodable {
            public let cachedContentTokenCount: Int?
            public let candidatesTokenCount: Int?
            public let promptTokenCount: Int?
            public let totalTokenCount: Int?
        }
        
        public struct FileUpload: Codable {
            public let file: _Gemini.File
        }
        
        public struct UploadInitiation: Decodable {
            public let uploadURL: URL
        }
        
        public struct TunedGenerateContent: Decodable {
            public let candidates: [Candidate]?
            public let usageMetadata: UsageMetadata?
            public let modelVersion: String?
            
            private enum CodingKeys: String, CodingKey {
                case candidates
                case usageMetadata
                case modelVersion
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.candidates = try container.decodeIfPresent([Candidate].self, forKey: .candidates)
                self.usageMetadata = try container.decodeIfPresent(UsageMetadata.self, forKey: .usageMetadata)
                self.modelVersion = try container.decodeIfPresent(String.self, forKey: .modelVersion)
                
                // Validate that we have either candidates or usage metadata
                guard candidates != nil || usageMetadata != nil else {
                    throw DecodingError.dataCorruptedError(
                        forKey: .candidates,
                        in: container,
                        debugDescription: "Response must contain either candidates or usage metadata"
                    )
                }
            }
        }
    }
}
