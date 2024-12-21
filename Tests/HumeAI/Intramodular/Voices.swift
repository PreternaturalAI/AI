//
// Copyright (c) Preternatural AI, Inc.
//

@testable import HumeAI
import XCTest

final class HumeAIClientVoiceTests: XCTestCase {
    
    func testListCustomVoices() async throws {
        let voices = try await client.listCustomVoices()
        
        for voice in voices {
            try await client.deleteCustomVoice(id: voice.id)
        }
        
        XCTAssertNotNil(voices)
    }
    
    func testCreateCustomVoice() async throws {
        let voice = try await createVoice()
        try await client.deleteCustomVoice(id: voice.id)
        
        XCTAssertNotNil(voice.id)
        XCTAssertEqual(voice.name, "TEST VOICE")
        XCTAssertEqual(voice.baseVoice, "ITO")
    }
    
    func testGetCustomVoice() async throws {
        let voice = try await createVoice()
        let retrievedVoice = try await client.getCustomVoice(id: voice.id)
        try await client.deleteCustomVoice(id: voice.id)
        
        XCTAssertEqual(retrievedVoice.id, voice.id)
    }
    
    func testCreateCustomVoiceVersion() async throws {
        let voiceVersion = try await createCustomVoiceVersion()
        
        try await client.deleteCustomVoice(id: voiceVersion.id)
        
        XCTAssertEqual(voiceVersion.baseVoice, "DACHER")
    }
    
    func testDeleteCustomVoice() async throws {
        let voice = try await createVoice()
        try await client.deleteCustomVoice(id: voice.id)
    }
    
    func testUpdateCustomVoiceName() async throws {
        let voice = try await createVoice()
        
        let updatedVoice = try await client.updateCustomVoiceName(
            id: voice.id,
            name: "Updated Voice Name"
        )
        
        try await client.deleteCustomVoice(id: voice.id)
    }
    
    func createCustomVoiceVersion() async throws -> HumeAI.Voice {
        let voice = try await client.createCustomVoice(
            name: "Test Voice 2",
            baseVoice: "ITO",
            parameterModel: HumeAI.parameterModel,
            parameters: createTestParameters()
        )
        
        return try await client.createCustomVoiceVersion(
            id: voice.id,
            baseVoice: "DACHER",
            parameterModel: HumeAI.parameterModel
        )
    }
    
    // Helper Methods
    func createVoice() async throws -> HumeAI.Voice {
        return try await client.createCustomVoice(
            name: "Test Voice",
            baseVoice: "ITO",
            parameterModel: HumeAI.parameterModel,
            parameters: createTestParameters()
        )
    }
    
    func createTestParameters() -> HumeAI.Voice.Parameters {
        return HumeAI.Voice.Parameters(
            gender: 0.5,
            articulation: 0.5,
            assertiveness: 0.5,
            buoyancy: 0.5,
            confidence: 0.5,
            enthusiasm: 0.5,
            nasality: 0.5,
            relaxedness: 0.5,
            smoothness: 0.5,
            tepidity: 0.5,
            tightness: 0.5
        )
    }
}
