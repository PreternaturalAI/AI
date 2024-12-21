//
// Copyright (c) Preternatural AI, Inc.
//

import AI
@testable import NeetsAI
import NetworkKit
import SwiftAPI
import XCTest

final class NeetsAIClientTests: XCTestCase {

    // MARK: - Voice Tests
    
    func test_getAllAvailableVoices_returnsVoicesList() async throws {
        // Given
        let mockVoices = [
            NeetsAI.Voice(id: "vits-ben-14", title: nil, aliasOf: nil, supportedModels: ["vits"]),
            NeetsAI.Voice(id: "vits-eng-2", title: nil, aliasOf: nil, supportedModels: ["vits"])
        ]
        
        // When
        let voices = try await client.getAllAvailableVoices()
        
        // Then
        XCTAssertEqual(voices.isEmpty, false)
    }
    
    // MARK: - Text to Speech Tests
    
    func test_generateSpeech_withDefaultParameters_returnsAudioData() async throws {
        // Given
        let text = "Hello, world!"
        let voiceId = "us-male-13"
        
        // When
        let audioData = try await client.generateSpeech(
            text: text,
            voiceId: voiceId
        )
        
        // Then
        XCTAssertFalse(audioData.isEmpty)
    }
    
    func test_generateSpeech_withCustomParameters_returnsAudioData() async throws {
        // Given
        let text = "Test speech"
        let voiceId = "us-male-13"
        let model = NeetsAI.Model.arDiff50k
        let temperature = 0.8
        let diffusionIterations = 10
        
        // When
        let audioData = try await client.generateSpeech(
            text: text,
            voiceId: voiceId,
            model: model,
            temperature: temperature,
            diffusionIterations: diffusionIterations
        )
        
        // Then
        XCTAssertFalse(audioData.isEmpty)
    }
    
    // MARK: - Chat Tests
    
    func test_chat_withDefaultModel_returnsCompletion() async throws {
        // Given
        let messages = [
            NeetsAI.ChatMessage(role: "user", content: "Hello", toolCalls: nil)
        ]
        
        // When
        let completion = try await client.chat(messages: messages)
        
        // Then
        XCTAssertFalse(completion.id.isEmpty)
        XCTAssertEqual(completion.object, "chat.completion")
        XCTAssertGreaterThan(completion.created, 0)
        XCTAssertEqual(completion.model, NeetsAI.Model.mistralai.rawValue)
        
        XCTAssertFalse(completion.choices.isEmpty)
        let firstChoice = try XCTUnwrap(completion.choices.first)
        XCTAssertEqual(firstChoice.index, 0)
        XCTAssertEqual(firstChoice.message.role, "assistant")
        XCTAssertFalse(firstChoice.message.content.isEmpty)
        
        XCTAssertGreaterThan(completion.usage.promptTokens, 0)
        XCTAssertGreaterThan(completion.usage.completionTokens, 0)
        XCTAssertGreaterThan(completion.usage.totalTokens, 0)
    }
    
    func test_chat_withCustomModel_usesSpecifiedModel() async throws {
        // Given
        let messages = [
            NeetsAI.ChatMessage(role: "user", content: "Test", toolCalls: nil)
        ]
        let model = NeetsAI.Model.mistralai
        
        // When
        let completion = try await client.chat(messages: messages, model: model)
        
        // Then
        XCTAssertEqual(completion.model, model.rawValue)
    }
}
