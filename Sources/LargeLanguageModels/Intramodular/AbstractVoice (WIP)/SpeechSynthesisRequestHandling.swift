//
//  SpeechSynthesisRequestHandling.swift
//  Voice
//
//  Created by Jared Davidson on 10/30/24.
//

import Foundation
import SwiftUI

public protocol SpeechToSpeechRequest {
    
}

public protocol SpeechToSpeechRequestHandling {
    
}

public protocol SpeechSynthesisRequestHandling: AnyObject {
    func availableVoices() async throws -> [AbstractVoice]
    
    func speech(
        for text: String,
        voiceID: String,
        voiceSettings: AbstractVoiceSettings,
        model: String
    ) async throws -> Data
    
    func speechToSpeech(
        inputAudioURL: URL,
        voiceID: String,
        voiceSettings: AbstractVoiceSettings,
        model: String
    ) async throws -> Data
    
    func upload(
        voiceWithName name: String,
        description: String,
        fileURL: URL
    ) async throws -> AbstractVoice.ID
    
    func edit(
        voice: AbstractVoice.ID,
        name: String,
        description: String,
        fileURL: URL?
    ) async throws -> Bool
    
    func delete(voice: AbstractVoice.ID) async throws
}

// MARK: - Environment Key

private struct AbstractClientKey: EnvironmentKey {
    static let defaultValue: (any SpeechSynthesisRequestHandling)? = nil
}

extension EnvironmentValues {
    public var speechSynthesizer: (any SpeechSynthesisRequestHandling)? {
        get { self[AbstractClientKey.self] }
        set { self[AbstractClientKey.self] = newValue }
    }
}
