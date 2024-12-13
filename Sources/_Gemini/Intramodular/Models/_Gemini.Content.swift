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
        public let role: String? = nil
        public let parts: [Part]
        
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
        
        public init(from decoder: Decoder) throws {
            // Initialize all required properties before throwing
            self.text = ""
            self.finishReason = nil
            self.safetyRatings = []
            self.tokenUsage = nil
            self.parts = []
            
            throw _Gemini.APIError.unknown(message: "Direct decoding not supported")
        }
    }
}

// Initializers

extension _Gemini.Content {
    init(apiResponse response: _Gemini.APISpecification.ResponseBodies.GenerateContent) throws {
        guard let candidate = response.candidates?.first,
              let content = candidate.content,
              let responseParts = content.parts else {
            throw _Gemini.APIError.unknown(message: "Invalid response format")
        }
        
        var parts: [Part] = []
        var textParts: [String] = []
        
        // Process all part types
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
    }
}
