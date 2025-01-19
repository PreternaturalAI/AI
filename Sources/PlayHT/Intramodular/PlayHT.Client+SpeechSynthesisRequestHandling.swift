//
//  PlayHT+SpeechSynthesisRequestHandling.swift
//  Voice
//
//  Created by Jared Davidson on 11/20/24.
//

import Foundation
import AI
import ElevenLabs
import SwiftUI
import AVFoundation
import LargeLanguageModels

extension PlayHT.Client: SpeechSynthesisRequestHandling {
    public func availableVoices() async throws -> [AbstractVoice] {
        let voices: [AbstractVoice] = try await getAllAvailableVoices().map { try $0.__conversion() }
        return voices
    }
    
    public func speech(for text: String, voiceID: String, voiceSettings: AbstractVoiceSettings, model: String) async throws -> Data {
        let data: Data = try await streamTextToSpeech(
            text: text,
            voice: voiceID,
            settings: .init(),
            model: .playHT2Turbo
        )
        
        return data
    }
    
    public func speechToSpeech(inputAudioURL: URL, voiceID: String, voiceSettings: LargeLanguageModels.AbstractVoiceSettings, model: String) async throws -> Data {
        throw PlayHT.APIError.unknown(message: "Speech to speech not supported")
    }
    
    public func upload(voiceWithName name: String, description: String, fileURL: URL) async throws -> AbstractVoice.ID {
        let mp4URL = try await fileURL.convertAudioToMP4()
        let fileURLString = mp4URL.absoluteString
        let voiceID = try await instantCloneVoice(
            sampleFileURL: fileURLString,
            name: name
        )
        
        try? FileManager.default.removeItem(at: mp4URL)
        
        return .init(rawValue: voiceID.rawValue)
    }
    
    public func edit(voice: LargeLanguageModels.AbstractVoice.ID, name: String, description: String, fileURL: URL?) async throws -> Bool {
        throw PlayHT.APIError.unknown(message: "Voice editing not supported")
    }
    
    public func delete(voice: LargeLanguageModels.AbstractVoice.ID) async throws {
        try await deleteClonedVoice(voice: .init(rawValue: voice.rawValue))
    }
}
