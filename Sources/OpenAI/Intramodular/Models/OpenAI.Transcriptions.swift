//
//  File.swift
//  
//
//  Created by Natasha Murashev on 4/23/24.
//

import Foundation

extension OpenAI {
    public final class Transcriptions: OpenAI.Object {
        public let data: Data
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.data = try container.decode(forKey: .data)
            
            try super.init(from: decoder)
        }
        
        public init(data: Data) {
            self.data = data
            super.init(type: .transcriptions)
        }
        
        enum CodingKeys: CodingKey {
            case data
        }
    }
}

