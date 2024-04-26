//
// Copyright (c) Vatsal Manot
//

import FoundationX

extension OpenAI {
    public final class AudioTranscription: OpenAI.Object {
        fileprivate enum CodingKeys: CodingKey {
            case text
        }

        public let text: String
                
        public init(text: String) {
            self.text = text
            
            super.init(type: .transcription)
        }
                
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.text = try container.decode(forKey: .text)
            
            try super.init(from: decoder)
        }
        
        override public func encode(to encoder: any Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(text, forKey: .text)
        }
    }
}
