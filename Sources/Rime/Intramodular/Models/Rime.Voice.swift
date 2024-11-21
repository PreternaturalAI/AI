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
        public let age: String?
        public let country: String?
        public let region: String?
        public let demographic: String?
        public let genre: [String]?
        
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
            self.name = try container.decode(String.self, forKey: Rime.Voice.CodingKeys.name)
            
            self.id = .init(rawValue: self.name)

            self.age = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.age)
            self.country = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.country)
            self.region = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.region)
            self.demographic = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.demographic)
            self.genre = try container.decodeIfPresent([String].self, forKey: Rime.Voice.CodingKeys.genre)
        }
    }
}
