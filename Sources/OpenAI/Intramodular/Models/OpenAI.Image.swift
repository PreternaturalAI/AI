//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import Swift

extension OpenAI {
    public final class Image: OpenAI.Object {
        enum CodingKeys: String, CodingKey {
            case url
            case revisedPrompt
        }
        
        public let url: String?
        public let revisedPrompt: String?
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
                        
            self.url = try container.decodeIfPresent(forKey: .url)
            self.revisedPrompt = try container.decodeIfPresent(forKey: .revisedPrompt)
            
            super.init(type: .image)
        }
    }
}

extension OpenAI.Image {
    /// The quality of the image that will be generated. hd creates images with finer details and greater consistency across the image. This param is only supported for dall-e-3.
    /// Defaults to standard
    public enum Quality: String, Codable, CaseIterable {
        case standard
        case hd
    }
    
    /// The size of the generated images. Must be one of 256x256, 512x512, or 1024x1024 for dall-e-2. Must be one of 1024x1024, 1792x1024, or 1024x1792 for dall-e-3 models.
    /// Defaults to 1024x1024
    public enum Size: String, Codable, CaseIterable {
        case w1024h1024 = "1024x1024"
        case w1792h1024 = "1792x1024"
        case w1024h1792 = "1024x1792"
    }
    
    /// The style of the generated images. Must be one of vivid or natural. Vivid causes the model to lean towards generating hyper-real and dramatic images. Natural causes the model to produce more natural, less hyper-real looking images. This param is only supported for dall-e-3.
    /// Defaults to vivid
    public enum Style: String, Codable, CaseIterable {
        case vivid
        case natural
    }
}
