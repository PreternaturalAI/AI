//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public final class Speech: OpenAI.Object {
        public let data: Data
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.data = try container.decode(forKey: .data)
            
            try super.init(from: decoder)
        }
        
        public init(data: Data) {
            self.data = data
            super.init(type: .speech)
        }
        
        enum CodingKeys: CodingKey {
            case data
        }
    }
}

extension OpenAI.Speech {
    /// Encapsulates the voices available for audio generation.
    ///
    /// To get aquinted with each of the voices and listen to the samples visit:
    /// [OpenAI Text-to-Speech – Voice Options](https://platform.openai.com/docs/guides/text-to-speech/voice-options)
    public enum Voice: String, Codable, CaseIterable {
        case alloy
        case echo
        case fable
        case onyx
        case nova
        case shimmer
    }
}
