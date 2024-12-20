//
//  _Gemini.TrainingData.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

extension _Gemini {
    public struct TrainingData: Codable {
        public let examples: FineTuningExamples
        
        public init(examples: FineTuningExamples) {
            self.examples = examples
        }
    }
}
