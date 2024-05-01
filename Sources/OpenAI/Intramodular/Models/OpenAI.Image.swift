//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/1/24.
//

import Foundation

extension OpenAI {
    public final class Image: OpenAI.Object {
        public let url: String?
        public let revisedPrompt: String?
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let data: [String: String] = try container.decode(forKey: .data)
            
            self.url = data["url"]
            self.revisedPrompt = data["revisedPrompt"]
            
            try super.init(from: decoder)
        }
        
        public init(data: [String : Any]) {
            self.url = data["url"] as! String?
            self.revisedPrompt = data["revisedPrompt"] as! String?
            super.init(type: .image)
        }
        
        enum CodingKeys: CodingKey {
            case data
        }
    }
}
