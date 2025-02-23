//
//  NeetsAI.Voice.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import Foundation
import LargeLanguageModels

extension NeetsAI {
    public struct Voice: Codable, Hashable {
        public let id: String
        public let title: String?
        public let aliasOf: String?
        public let supportedModels: [String]
    }
}

extension NeetsAI.Voice: AbstractVoiceConvertible {
    public func __conversion() throws -> AbstractVoice {
        return AbstractVoice(
            voiceID: self.id,
            name: self.title ?? "",
            description: self.aliasOf
        )
    }
}

extension NeetsAI.Voice: AbstractVoiceInitiable {
    public init(voice: AbstractVoice) throws {
        self.init(
            id: .init(voice.voiceID),
            title: voice.name,
            aliasOf: voice.description,
            supportedModels: []
        )
    }
}
