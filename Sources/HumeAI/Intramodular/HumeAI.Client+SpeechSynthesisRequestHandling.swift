//
//  HumeAI+ElevenLabsClientProtocol.swift
//  Voice
//
//  Created by Jared Davidson on 11/22/24.
//

import Foundation
import SwiftUI
import AVFoundation
import LargeLanguageModels

extension HumeAI.Client: SpeechSynthesisRequestHandling {
    public func availableVoices() async throws -> [AbstractVoice] {
        return try await getAllAvailableVoices().map(
            { voice in
                return AbstractVoice(
                    voiceID: voice.id,
                    name: voice.name,
                    description: nil
                )
        })
    }
    
    public func speech(for text: String, voiceID: String, voiceSettings: AbstractVoiceSettings, model: String) async throws -> Data {
        throw HumeAI.APIError.unknown(message: "Text to speech not supported")
    }
    
    public func speechToSpeech(inputAudioURL: URL, voiceID: String, voiceSettings: AbstractVoiceSettings, model: String) async throws -> Data {
        throw HumeAI.APIError.unknown(message: "Speech to speech not supported")
    }
    
    public func upload(voiceWithName name: String, description: String, fileURL: URL) async throws -> AbstractVoice.ID {
        throw HumeAI.APIError.unknown(message: "Voice creation is not supported")
    }
    
    public func edit(voice: AbstractVoice.ID, name: String, description: String, fileURL: URL?) async throws -> Bool {
        throw HumeAI.APIError.unknown(message: "Voice creation is not supported")
    }
    
    public func delete(voice: AbstractVoice.ID) async throws {
        throw HumeAI.APIError.unknown(message: "Voice creation is not supported")
    }
}
