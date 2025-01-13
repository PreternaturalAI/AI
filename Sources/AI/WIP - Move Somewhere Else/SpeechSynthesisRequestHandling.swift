//
//  SpeechSynthesisRequestHandling.swift
//  Voice
//
//  Created by Jared Davidson on 10/30/24.
//

import Foundation
import AI
import ElevenLabs
import SwiftUI

public protocol SpeechToSpeechRequest {
    
}

public protocol SpeechToSpeechRequestHandling {
    
}

public protocol SpeechSynthesisRequestHandling: AnyObject {
    func availableVoices() async throws -> [ElevenLabs.Voice]
    
    func speech(
        for text: String,
        voiceID: String,
        voiceSettings: ElevenLabs.VoiceSettings,
        model: ElevenLabs.Model
    ) async throws -> Data
    
    func speechToSpeech(
        inputAudioURL: URL,
        voiceID: String,
        voiceSettings: ElevenLabs.VoiceSettings,
        model: ElevenLabs.Model
    ) async throws -> Data
    
    func upload(
        voiceWithName name: String,
        description: String,
        fileURL: URL
    ) async throws -> ElevenLabs.Voice.ID
    
    func edit(
        voice: ElevenLabs.Voice.ID,
        name: String,
        description: String,
        fileURL: URL?
    ) async throws -> Bool
    
    func delete(voice: ElevenLabs.Voice.ID) async throws
}

// MARK: - Environment Key

private struct ElevenLabsClientKey: EnvironmentKey {
    static let defaultValue: (any SpeechSynthesisRequestHandling)? = ElevenLabs.Client(apiKey: "")
}

extension EnvironmentValues {
    public var speechSynthesizer: (any SpeechSynthesisRequestHandling)? {
        get { self[ElevenLabsClientKey.self] }
        set { self[ElevenLabsClientKey.self] = newValue }
    }
}

// MARK: - Conformances

extension ElevenLabs.Client: SpeechSynthesisRequestHandling {}


public struct AnySpeechSynthesisRequestHandling: Hashable {
    private let _hashValue: Int

    public let base: any CoreMI._ServiceClientProtocol & SpeechSynthesisRequestHandling

    public var displayName: String {
        switch base {
            case is ElevenLabs.Client:
                return "ElevenLabs"
            default:
                fatalError()
        }
    }
    
    public init(
        _ base: any CoreMI._ServiceClientProtocol & SpeechSynthesisRequestHandling
    ) {
        self.base = base
        self._hashValue = ObjectIdentifier(base as AnyObject).hashValue
    }

    public static func == (lhs: AnySpeechSynthesisRequestHandling, rhs: AnySpeechSynthesisRequestHandling) -> Bool {
        lhs._hashValue == rhs._hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }
}
