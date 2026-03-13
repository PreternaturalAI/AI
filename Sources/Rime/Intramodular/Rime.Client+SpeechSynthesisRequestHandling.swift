//
//  Rime+SpeechSynthesisRequestHandling.swift
//  Voice
//
//  Created by Jared Davidson on 11/21/24.
//

import LargeLanguageModels
import Foundation
import SwiftUI
import AVFoundation

extension Rime.Client: SpeechSynthesisRequestHandling {
    public func availableVoices() async throws -> [AbstractVoice] {
        return try await getAllAvailableVoiceDetails().map { try $0.__conversion() }
    }
    
    public func speech(for text: String, voiceID: String, voiceSettings: AbstractVoiceSettings, model: String) async throws -> Data {
        return try await streamTextToSpeech(
            text: text,
            voice: voiceID,
            outputAudio: .MP3,
            model: .mist
        )
    }
    
    public func speechToSpeech(inputAudioURL: URL, voiceID: String, voiceSettings: AbstractVoiceSettings, model: String) async throws -> Data {
        throw Rime.APIError.unknown(message: "Speech to speech not supported")
    }
    
    public func upload(voiceWithName name: String, description: String, fileURL: URL) async throws -> AbstractVoice.ID {
        throw Rime.APIError.unknown(message: "Voice creation is not supported")
    }
    
    public func edit(voice: AbstractVoice.ID, name: String, description: String, fileURL: URL?) async throws -> Bool {
        throw Rime.APIError.unknown(message: "Voice creation is not supported")
    }
    
    public func delete(voice: AbstractVoice.ID) async throws {
        throw Rime.APIError.unknown(message: "Voice creation is not supported")
    }
}
