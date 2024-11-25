//
//  Voices.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientCustomVoiceTests: XCTestCase {
    
    func testListCustomVoices() async throws {
        let voices = try await client.listCustomVoices()
        XCTAssertNotNil(voices)
    }
    
    func testCreateCustomVoice() async throws {
        let voice = try await client.createCustomVoice(
            name: "Test Voice",
            baseVoice: "base-voice",
            model: .prosody,
            parameters: .init()
        )
        XCTAssertEqual(voice.name, "Test Voice")
    }
    
    func testDeleteCustomVoice() async throws {
        try await client.deleteCustomVoice(id: "test-id")
    }
    
    func testGetCustomVoice() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testCreateCustomVoiceVersion() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
    
    func testUpdateCustomVoiceName() async throws {
        print("Needs Implementation")
        XCTFail("Not implemented")
    }
}
