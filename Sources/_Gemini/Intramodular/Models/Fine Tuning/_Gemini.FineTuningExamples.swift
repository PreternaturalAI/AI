//
// Copyright (c) Preternatural AI, Inc.
//

extension _Gemini {
    public struct FineTuningExamples: Codable {
        public let examples: [FineTuningExample]
        
        public init(examples: [FineTuningExample]) {
            self.examples = examples
        }
    }
}
