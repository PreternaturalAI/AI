//
//  NeetsAI.Voice.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import Foundation

extension NeetsAI {
    public struct Voice: Codable, Hashable {
        public let id: String
        public let title: String?
        public let aliasOf: String?
        public let supportedModels: [String]
    }
}
