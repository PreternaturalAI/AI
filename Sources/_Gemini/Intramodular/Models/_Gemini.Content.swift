//
//  _Gemini.Content.swift
//  AI
//
//  Created by Jared Davidson on 12/12/24.
//

import Foundation

extension _Gemini {
    public struct Content: Decodable {
        public let text: String
        public let finishReason: FinishReason?
        public let safetyRatings: [SafetyRating]
        public let tokenUsage: TokenUsage?
        
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
        
        // Custom initializer for API response
        init(apiResponse response: _Gemini.APISpecification.ResponseBodies.GenerateContent) throws {
            guard let candidate = response.candidates?.first,
                  let content = candidate.content,
                  let parts = content.parts else {
                throw _Gemini.APIError.unknown(message: "Invalid response format")
            }
            
            // Combine all text parts
            self.text = parts.compactMap { part -> String? in
                if case .text(let text) = part {
                    return text
                }
                return nil
            }.joined(separator: " ")
            
            // Map finish reason
            if let finishReasonStr = candidate.finishReason {
                self.finishReason = FinishReason(rawValue: finishReasonStr)
            } else {
                self.finishReason = nil
            }
            
            // Map safety ratings
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
            
            // Map token usage
            if let usage = response.usageMetadata {
                self.tokenUsage = TokenUsage(
                    prompt: usage.promptTokenCount ?? 0,
                    response: usage.candidatesTokenCount ?? 0,
                    total: usage.totalTokenCount ?? 0
                )
            } else {
                self.tokenUsage = nil
            }
        }
        
        // Required Decodable implementation
        public init(from decoder: Decoder) throws {
            // This would be implemented if we need to decode Content directly from JSON
            // For now, we'll throw an error as we expect to create Content from our API response
            throw _Gemini.APIError.unknown(message: "Direct decoding not supported")
        }
    }
}
