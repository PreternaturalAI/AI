//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension _Gemini {
    public struct Tool: Codable {
        private enum CodingKeys: String, CodingKey {
            case functionDeclarations = "function_declarations"
            case codeExecution = "code_execution"
            case googleSearchRetrieval = "google_search_retrieval"
        }
        
        public let functionDeclarations: [_Gemini.FunctionDefinition]?
        public let codeExecutionEnabled: Bool
        public let googleSearchRetrieval: _Gemini.GoogleSearchRetrieval?
        
        public init(functionDeclarations: [_Gemini.FunctionDefinition]? = nil) {
            self.functionDeclarations = functionDeclarations
            self.codeExecutionEnabled = false
            self.googleSearchRetrieval = nil
        }
        
        public init(codeExecutionEnabled: Bool = true) {
            self.functionDeclarations = nil
            self.codeExecutionEnabled = codeExecutionEnabled
            self.googleSearchRetrieval = nil
        }
        
        public init(googleSearchRetrieval: _Gemini.GoogleSearchRetrieval) {
            self.functionDeclarations = nil
            self.codeExecutionEnabled = false
            self.googleSearchRetrieval = googleSearchRetrieval
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encodeIfPresent(functionDeclarations, forKey: .functionDeclarations)
            if codeExecutionEnabled {
                try container.encode([String: String](), forKey: .codeExecution)
            }
            try container.encodeIfPresent(googleSearchRetrieval, forKey: .googleSearchRetrieval)
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            self.functionDeclarations = try container.decodeIfPresent([_Gemini.FunctionDefinition].self, forKey: .functionDeclarations)
            self.codeExecutionEnabled = false
            self.googleSearchRetrieval = try container.decodeIfPresent(_Gemini.GoogleSearchRetrieval.self, forKey: .googleSearchRetrieval)
        }
    }
}
