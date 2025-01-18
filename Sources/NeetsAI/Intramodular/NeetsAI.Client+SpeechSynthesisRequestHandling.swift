//
//  NeetsAI.Client+SpeechSynthesisRequestHandling.swift
//  Voice
//

import Foundation
import SwiftUI
import AVFoundation
import LargeLanguageModels

extension NeetsAI.Client: SpeechSynthesisRequestHandling {
    public func availableVoices() async throws -> [AbstractVoice] {
        let voices = try await getAllAvailableVoices()
            .map({ try $0.__conversion() })
            .filter({ !$0.name.isEmpty })
            .unique(by: \.name)
        return voices
    }
    
    public func speech(for text: String, voiceID: String, voiceSettings: LargeLanguageModels.AbstractVoiceSettings, model: String) async throws -> Data {
        let audio = try await generateSpeech(
            text: text,
            voiceId: voiceID,
            model: .init(rawValue: model) ?? .mistralai
        )
        return audio
    }
    
    public func speechToSpeech(inputAudioURL: URL, voiceID: String, voiceSettings: LargeLanguageModels.AbstractVoiceSettings, model: String) async throws -> Data {
        throw NeetsAI.APIError.unknown(message: "Speech to speech not supported")

    }
    
    public func upload(voiceWithName name: String, description: String, fileURL: URL) async throws -> LargeLanguageModels.AbstractVoice.ID {
        throw NeetsAI.APIError.unknown(message: "Uploading Voice is not supported")
    }
    
    public func edit(voice: LargeLanguageModels.AbstractVoice.ID, name: String, description: String, fileURL: URL?) async throws -> Bool {
        throw NeetsAI.APIError.unknown(message: "Editing Voice is not supported")
    }
    
    public func delete(voice: LargeLanguageModels.AbstractVoice.ID) async throws {
        throw NeetsAI.APIError.unknown(message: "Deleting Voice is not supported")
    }
}

// FIXME: - REMOVE ME
extension Sequence {
    func unique<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
}
