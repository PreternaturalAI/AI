//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public class List<T: Codable>: Object {
        private enum CodingKeys: String, CodingKey {
            case data
            case hasMore
            case firstID = "firstId"
            case lastID = "lastId"
        }
        
        public let data: [T]
        public let hasMore: Bool?
        public let firstID: String?
        public let lastID: String?
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.data = try container.decode(forKey: .data)
            self.hasMore = try container.decodeIfPresent(forKey: .hasMore)
            self.firstID = try container.decodeIfPresent(forKey: .firstID)
            self.lastID = try container.decodeIfPresent(forKey: .lastID)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(data, forKey: .data)
            try container.encode(hasMore, forKey: .hasMore)
            try container.encode(firstID, forKey: .firstID)
            try container.encode(lastID, forKey: .lastID)
        }
    }
}
