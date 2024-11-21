//
//  Rime.Voice.swift
//  AI
//
//  Created by Jared Davidson on 11/21/24.
//

import Foundation
import Swallow

extension Rime {
    public struct Voice: Codable, Hashable, Identifiable {
        public typealias ID = _TypeAssociatedID<Self, String>
        
        public let id: ID
        public let name: String
        public let age: String
        public let country: String
        public let region: String
        public let demographic: String
        public let genre: [String]
        
        enum CodingKeys: CodingKey {
            case id
            case name
            case age
            case country
            case region
            case demographic
            case genre
        }
        
        public init(from decoder: any Decoder) throws {
            let container: KeyedDecodingContainer<Rime.Voice.CodingKeys> = try decoder.container(keyedBy: Rime.Voice.CodingKeys.self)
            self.id = try container.decode(Rime.Voice.ID.self, forKey: Rime.Voice.CodingKeys.id)
            self.name = try container.decode(String.self, forKey: Rime.Voice.CodingKeys.name)
            self.age = try container.decode(String.self, forKey: Rime.Voice.CodingKeys.age)
            self.country = try container.decode(String.self, forKey: Rime.Voice.CodingKeys.country)
            self.region = try container.decode(String.self, forKey: Rime.Voice.CodingKeys.region)
            self.demographic = try container.decode(String.self, forKey: Rime.Voice.CodingKeys.demographic)
            self.genre = try container.decode([String].self, forKey: Rime.Voice.CodingKeys.genre)
        }
        
        public func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: Rime.Voice.CodingKeys.self)
            try container.encode(self.id, forKey: Rime.Voice.CodingKeys.id)
            try container.encode(self.name, forKey: Rime.Voice.CodingKeys.name)
            try container.encode(self.age, forKey: Rime.Voice.CodingKeys.age)
            try container.encode(self.country, forKey: Rime.Voice.CodingKeys.country)
            try container.encode(self.region, forKey: Rime.Voice.CodingKeys.region)
            try container.encode(self.demographic, forKey: Rime.Voice.CodingKeys.demographic)
            try container.encode(self.genre, forKey: Rime.Voice.CodingKeys.genre)
        }
        
    }
}
