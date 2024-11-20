//
//  SpeechTests.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import PlayHT
import XCTest

final class PlayHTTests: XCTestCase {
    
    let sampleText = "In a quiet, unassuming village nestled deep in a lush, verdant valley, young Elara leads a simple life, dreaming of adventure beyond the horizon. Her village is filled with ancient folklore and tales of mystical relics, but none capture her imagination like the legend of the Enchanted Amulet—a powerful artifact said to grant its bearer the ability to control time."
    
    func testListVoices() async throws {
        let voices = try await client.availableVoices()
        XCTAssertFalse(voices.isEmpty)
    }
    
    func testCreateSpeech() async throws {
        let voices = try await client.availableVoices()
        let voice = try XCTUnwrap(voices.first)
        
        let voiceSettings = PlayHT.VoiceSettings(
            speed: 1.0,
            temperature: 0.7,
            voiceGuidance: 3.0,
            styleGuidance: 15.0,
            textGuidance: 1.5
        )
        
        let outputSettings = PlayHT.OutputSettings(
            quality: .high,
            format: .mp3,
            sampleRate: 48000
        )
        
        let audioURL = try await client.generateSpeech(
            text: sampleText,
            voice: voice,
            settings: voiceSettings,
            outputSettings: outputSettings
        )
        
        XCTAssertNotNil(audioURL)
    }
    
    func testStreamSpeech() async throws {
        let voices = try await client.availableVoices()
        let voice = try XCTUnwrap(voices.first)
        
        let voiceSettings = PlayHT.VoiceSettings()
        let outputSettings = PlayHT.OutputSettings()
        
        let data = try await client.streamSpeech(
            text: sampleText,
            voice: voice,
            settings: voiceSettings,
            outputSettings: outputSettings
        )
        
        XCTAssertFalse(data.isEmpty)
    }
    
    func testInstantCloneVoice() async throws {
        let sampleURL = "https://example.com/sample.mp3"
        let voiceID = try await client.instantCloneVoice(
            sampleFileURL: sampleURL,
            name: "Test Clone"
        )
        
        XCTAssertNotNil(voiceID)
    }
}
