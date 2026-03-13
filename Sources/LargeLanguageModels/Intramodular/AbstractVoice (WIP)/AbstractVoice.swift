//
//  AudioStore.swift
//  Voice
//
//  Created by Jared Davidson on 10/31/24.
//

import CorePersistence
import SwiftUI
import AVFoundation
import UniformTypeIdentifiers

public struct AbstractVoice: Codable, Hashable, Identifiable, Sendable {
    public typealias ID = _TypeAssociatedID<Self, String>
    
    public let id: ID
    public let voiceID: String
    public let name: String
    public let description: String?
    
    public init(
        voiceID: String,
        name: String,
        description: String?
    ) {
        self.id = .init(rawValue: voiceID)
        self.voiceID = voiceID
        self.name = name
        self.description = description
    }
}

// MARK: - Conformances

public protocol AbstractVoiceInitiable {
    init(voice: AbstractVoice) throws
}

public protocol AbstractVoiceConvertible {
    func __conversion() throws -> AbstractVoice
}
