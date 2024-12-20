//
// Copyright (c) Vatsal Manot
//

import Foundation
import LargeLanguageModels
import Swallow

extension _Gemini {
    public struct Content: Decodable {
        public let text: String
        public let finishReason: FinishReason?
        public let safetyRatings: [SafetyRating]
        public let tokenUsage: TokenUsage?
        public let role: String? = nil
        public let parts: [Part]
        public let groundingMetadata: GroundingMetadata?
        
        public enum Part {
            case text(String)
            case functionCall(_Gemini.FunctionCall)
            case executableCode(language: String, code: String)
            case codeExecutionResult(outcome: String, output: String)
        }
        
        public enum FinishReason: String, Decodable {
            case maxTokens = "MAX_TOKENS"
            case stop = "STOP"
            case safety = "SAFETY"
            case recitation = "RECITATION"
            case other = "OTHER"
        }
        
        public struct SafetyRating: Decodable {
            public let category: Category
            public let probability: Probability
            public let blocked: Bool
            
            public enum Category: String, Decodable {
                case harassment = "HARM_CATEGORY_HARASSMENT"
                case hateSpeech = "HARM_CATEGORY_HATE_SPEECH"
                case sexuallyExplicit = "HARM_CATEGORY_SEXUALLY_EXPLICIT"
                case dangerousContent = "HARM_CATEGORY_DANGEROUS_CONTENT"
                case civicIntegrity = "HARM_CATEGORY_CIVIC_INTEGRITY"
            }
            
            public enum Probability: String, Decodable {
                case negligible = "NEGLIGIBLE"
                case low = "LOW"
                case medium = "MEDIUM"
                case high = "HIGH"
            }
        }
        
        public struct TokenUsage: Decodable {
            public let prompt: Int
            public let response: Int
            public let total: Int
        }
        
        public struct GroundingMetadata: Decodable {
            public let searchEntryPoint: SearchEntryPoint?
            public let groundingChunks: [WebSource]
            public let groundingSupports: [GroundingSupport]
            public let webSearchQueries: [String]
            
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
        
        public init(from decoder: Decoder) throws {
            self.text = ""
            self.finishReason = nil
            self.safetyRatings = []
            self.tokenUsage = nil
            self.parts = []
            self.groundingMetadata = nil
            
            throw _Gemini.APIError.unknown(message: "Direct decoding not supported")
        }
    }
}

extension _Gemini.Content {
    init(
        apiResponse response: _Gemini.APISpecification.ResponseBodies.GenerateContent
    ) throws {
        guard let candidate = response.candidates?.first,
              let content = candidate.content,
              let responseParts = content.parts else {
            throw _Gemini.APIError.unknown(message: "Invalid response format")
        }
        
        var parts: [Part] = []
        var textParts: [String] = []
        
        for part in responseParts {
            switch part {
                case .text(let text):
                    parts.append(.text(text))
                    textParts.append(text)
                case .executableCode(let language, let code):
                    parts.append(.executableCode(language: language, code: code))
                    textParts.append("```\(language.lowercased())\n\(code)\n```")
                case .codeExecutionResult(let outcome, let output):
                    parts.append(.codeExecutionResult(outcome: outcome, output: output))
                    textParts.append("Execution Result (\(outcome)):\n\(output)")
                case .functionCall(let call):
                    parts.append(.functionCall(call))
                    textParts.append("Function Call: \(call.name) with args: \(call.args)")
            }
        }
        
        self.parts = parts
        self.text = textParts.filter { !$0.isEmpty }.joined(separator: "\n\n")
        
        if let finishReasonStr = candidate.finishReason {
            self.finishReason = FinishReason(rawValue: finishReasonStr)
        } else {
            self.finishReason = nil
        }
        
        self.safetyRatings = (candidate.safetyRatings ?? []).compactMap { rating -> SafetyRating? in
            guard let category = rating.category,
                  let probability = rating.probability else {
                return nil
            }
            
            return SafetyRating(
                category: SafetyRating.Category(rawValue: category) ?? .dangerousContent,
                probability: SafetyRating.Probability(rawValue: probability) ?? .negligible,
                blocked: rating.blocked ?? false
            )
        }
        
        if let usage = response.usageMetadata {
            self.tokenUsage = TokenUsage(
                prompt: usage.promptTokenCount ?? 0,
                response: usage.candidatesTokenCount ?? 0,
                total: usage.totalTokenCount ?? 0
            )
        } else {
            self.tokenUsage = nil
        }
        
        if let metadata = candidate.groundingMetadata {
            let searchEntryPoint = metadata.searchEntryPoint.map {
                GroundingMetadata.SearchEntryPoint(renderedContent: $0.renderedContent)
            }
            
            let groundingChunks = (metadata.groundingChunks ?? []).map {
                GroundingMetadata.WebSource(
                    web: .init(
                        uri: $0.web.uri,
                        title: $0.web.title
                    )
                )
            }
            
            let groundingSupports = (metadata.groundingSupports ?? []).map {
                GroundingMetadata.GroundingSupport(
                    segment: .init(
                        startIndex: $0.segment.startIndex,
                        endIndex: $0.segment.endIndex,
                        text: $0.segment.text
                    ),
                    groundingChunkIndices: $0.groundingChunkIndices,
                    confidenceScores: $0.confidenceScores
                )
            }
            
            self.groundingMetadata = GroundingMetadata(
                searchEntryPoint: searchEntryPoint,
                groundingChunks: groundingChunks,
                groundingSupports: groundingSupports,
                webSearchQueries: metadata.webSearchQueries ?? []
            )
        } else {
            self.groundingMetadata = nil
        }
    }
    
    init(
        apiResponse response: _Gemini.APISpecification.ResponseBodies.TunedGenerateContent
    ) throws {
        if response.candidates == nil || response.candidates?.isEmpty == true {
            guard let usage = response.usageMetadata else {
                throw _Gemini.APIError.unknown(message: "Response missing both candidates and usage metadata")
            }
            
            self.text = ""
            self.finishReason = .other  // Set a default finish reason
            self.safetyRatings = []
            self.parts = []
            self.groundingMetadata = nil
            self.tokenUsage = TokenUsage(
                prompt: usage.promptTokenCount ?? 0,
                response: usage.candidatesTokenCount ?? 0,
                total: usage.totalTokenCount ?? 0
            )
            return
        }
        
        guard let candidate = response.candidates?.first,
              let content = candidate.content else {
            throw _Gemini.APIError.unknown(message: "Invalid candidate format")
        }
        
        var parts: [Part] = []
        var textParts: [String] = []
        
        if let responseParts = content.parts {
            for part in responseParts {
                switch part {
                    case .text(let text):
                        let normalizedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
                        parts.append(.text(normalizedText))
                        textParts.append(normalizedText)
                    case .functionCall(let call):
                        parts.append(.functionCall(call))
                        textParts.append("Function Call: \(call.name)")
                    case .executableCode(let language, let code):
                        parts.append(.executableCode(language: language, code: code))
                        textParts.append("```\(language)\n\(code)\n```")
                    case .codeExecutionResult(let outcome, let output):
                        parts.append(.codeExecutionResult(outcome: outcome, output: output))
                        textParts.append("\(outcome): \(output)")
                }
            }
        }
        
        self.parts = parts
        self.text = textParts.joined(separator: "\n\n")
        
        // Handle finish reason with a default value if not present
        self.finishReason = candidate.finishReason
            .flatMap { FinishReason(rawValue: $0) } ?? .other
        
        self.safetyRatings = (candidate.safetyRatings ?? []).compactMap { rating -> SafetyRating? in
            guard let category = rating.category,
                  let probability = rating.probability else {
                return nil
            }
            
            return SafetyRating(
                category: SafetyRating.Category(rawValue: category) ?? .dangerousContent,
                probability: SafetyRating.Probability(rawValue: probability) ?? .negligible,
                blocked: rating.blocked ?? false
            )
        }
        
        self.tokenUsage = response.usageMetadata.map {
            TokenUsage(
                prompt: $0.promptTokenCount ?? 0,
                response: $0.candidatesTokenCount ?? 0,
                total: $0.totalTokenCount ?? 0
            )
        }
        self.groundingMetadata = nil
    }
}
