//
// Copyright (c) Preternatural AI, Inc.
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
