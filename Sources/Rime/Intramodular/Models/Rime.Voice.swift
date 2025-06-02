//
//  Rime.Voice.swift
//  AI
//
//  Created by Jared Davidson on 11/21/24.
//

import Foundation
import CorePersistence
import Swallow
import LargeLanguageModels

extension Rime {
    public struct Voice: Hashable {
        public typealias ID = _TypeAssociatedID<Self, String>
        
        public init(
            name: String,
            age: String?,
            country: String?,
            region: String?,
            demographic: String?,
            genre: [String]?
        ) {
            self.id = .init(rawValue: UUID().uuidString)
            self.name = name
            self.age = age
            self.country = country
            self.region = region
            self.demographic = demographic
            self.genre = genre
        }

        public let id: ID
        public let name: String
        public let age: String?
        public let country: String?
        public let region: String?
        public let demographic: String?
        public let genre: [String]?
    }
}

// MARK: - Conformances

extension Rime.Voice: Codable {
    enum CodingKeys: CodingKey {
        case name
        case age
        case country
        case region
        case demographic
        case genre
    }
    
    public init(
        from decoder: any Decoder
    ) throws {
        let container: KeyedDecodingContainer<Rime.Voice.CodingKeys> = try decoder.container(keyedBy: Rime.Voice.CodingKeys.self)
        
        self.name = try container.decode(String.self, forKey: Rime.Voice.CodingKeys.name)
        self.age = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.age)
        self.country = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.country)
        self.region = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.region)
        self.demographic = try container.decodeIfPresent(String.self, forKey: Rime.Voice.CodingKeys.demographic)
        self.genre = try container.decodeIfPresent([String].self, forKey: Rime.Voice.CodingKeys.genre)
        
        self.id = .init(rawValue: UUID().uuidString)
    }
}

extension Rime.Voice: AbstractVoiceInitiable {
    public init(voice: AbstractVoice) throws {
        self.init(
            name: voice.name,
            age: nil,
            country: nil,
            region: nil,
            demographic: nil,
            genre: nil
        )
    }
}

extension Rime.Voice: AbstractVoiceConvertible {
    public func __conversion() throws -> AbstractVoice {
        return AbstractVoice(
            voiceID: self.id.rawValue,
            name: self.name,
            description: nil
        )
    }
}
