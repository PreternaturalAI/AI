//
// Copyright (c) Preternatural AI, Inc.
//

extension _Gemini {
    public struct TrainingData: Codable {
        public let examples: FineTuningExamples
        
        public init(examples: FineTuningExamples) {
            self.examples = examples
        }
    }
}
