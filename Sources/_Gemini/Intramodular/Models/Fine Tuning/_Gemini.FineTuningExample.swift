//
//  _Gemini.FineTuningExample.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//


extension _Gemini {
    public struct FineTuningExample: Codable {
        public let textInput: String
        public let output: String
        
        private enum CodingKeys: String, CodingKey {
            case textInput = "text_input"
            case output
        }
        
        public init(textInput: String, output: String) {
            self.textInput = textInput
            self.output = output
        }
    }
}
