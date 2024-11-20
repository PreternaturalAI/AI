//
//  PlayHT.Model.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import CoreMI
import CorePersistence
import Foundation
import Swift

extension PlayHT {
    public struct Voice: Codable, Hashable, Identifiable {
        public let id: String
        public let name: String
        public let category: String?
        public let language: String
        public let gender: String?
        public let isCloned: Bool
        public let isPreview: Bool
        public let previewUrl: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case name
            case category
            case language
            case gender
            case isCloned = "cloned"
            case isPreview = "preview"
            case previewUrl
        }
    }
}
