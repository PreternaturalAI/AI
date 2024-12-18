//
//  _Gemini.FineTuningExamples.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

extension _Gemini {
    public struct FineTuningExamples: Codable {
        public let examples: [FineTuningExample]
        
        public init(examples: [FineTuningExample]) {
            self.examples = examples
        }
    }
}
