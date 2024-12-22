//
// Copyright (c) Vatsal Manot
//

import ElevenLabs
import XCTest

final class SpeechTests: XCTestCase {
        
    func testCreateSpeech() async throws {
        
        let text = "In a quiet, unassuming village nestled deep in a lush, verdant valley, young Elara leads a simple life, dreaming of adventure beyond the horizon. Her village is filled with ancient folklore and tales of mystical relics, but none capture her imagination like the legend of the Enchanted Amulet—a powerful artifact said to grant its bearer the ability to control time."
        
        let voiceID = "4v7HtLWqY9rpQ7Cg2GT4"
        
        let voiceSettings: ElevenLabs.VoiceSettings = .init(
            stability: 0.5,
            similarityBoost: 0.75,
            styleExaggeration: 0,
            speakerBoost: true)
        
        let model = ElevenLabs.Model.EnglishV1
        
        let speechData = try await client.speech(
            for: text,
            voiceID: voiceID,
            voiceSettings: voiceSettings,
            model: model
        )
        
        XCTAssertFalse(speechData.isEmpty, "speechData should not be empty")
        
        _ = speechData
    }
}
