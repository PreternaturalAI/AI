//
//  _Gemini.GoogleSearchRetrieval.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Foundation

extension _Gemini {
    public struct GoogleSearchRetrieval: Codable {
        private enum CodingKeys: String, CodingKey {
            case dynamicRetrievalConfig = "dynamic_retrieval_config"
        }
        
        public let dynamicRetrievalConfig: DynamicRetrievalConfig
        
        public init(dynamicRetrievalConfig: DynamicRetrievalConfig) {
            self.dynamicRetrievalConfig = dynamicRetrievalConfig
        }
    }
    
    public struct DynamicRetrievalConfig: Codable {
        private enum CodingKeys: String, CodingKey {
            case mode
            case dynamicThreshold = "dynamic_threshold"
        }
        
        public let mode: String
        public let dynamicThreshold: Double
        
        public init(mode: String = "MODE_DYNAMIC", dynamicThreshold: Double) {
            self.mode = mode
            self.dynamicThreshold = dynamicThreshold
        }
    }
}
