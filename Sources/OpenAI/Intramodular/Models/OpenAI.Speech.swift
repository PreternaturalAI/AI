//
//  OpenAI.Speech.swift
//  graph
//
//  Created by Purav Manot on 10/03/24.
//

import Foundation

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
