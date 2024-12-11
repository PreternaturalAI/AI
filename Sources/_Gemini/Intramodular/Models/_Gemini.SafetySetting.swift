//
//  _Gemini.SafetySettings.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Foundation

extension _Gemini {
    public struct SafetySetting: Codable {
        public enum Category: String, Codable {
            case harassment = "HARM_CATEGORY_HARASSMENT"
            case hateSpeech = "HARM_CATEGORY_HATE_SPEECH"
            case sexuallyExplicit = "HARM_CATEGORY_SEXUALLY_EXPLICIT"
            case dangerousContent = "HARM_CATEGORY_DANGEROUS_CONTENT"
            case civicIntegrity = "HARM_CATEGORY_CIVIC_INTEGRITY"
        }
        
        public enum HarmBlockThreshold: String, Codable {
            case none = "BLOCK_NONE"
            case high = "BLOCK_ONLY_HIGH"
            case mediumAndAbove = "BLOCK_MEDIUM_AND_ABOVE"
            case lowAndAbove = "BLOCK_LOW_AND_ABOVE"
            case unspecified = "HARM_BLOCK_THRESHOLD_UNSPECIFIED"
        }
        
        public let category: Category
        public let threshold: HarmBlockThreshold
        
        public init(category: Category, threshold: HarmBlockThreshold) {
            self.category = category
            self.threshold = threshold
        }
    }
}
