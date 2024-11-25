//
//  Chat.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import XCTest
@testable import HumeAI

final class HumeAIClientChatTests: XCTestCase {
    
    func testListChats() async throws {
        let chats = try await client.listChats()
        XCTAssertNotNil(chats)
    }
    
    func testListChatEvents() async throws {
        let events = try await client.listChatEvents(chatId: "test-id")
        XCTAssertNotNil(events)
    }
    
    func testGetChatAudio() async throws {
        let audio = try await client.getChatAudio(chatId: "test-id")
        XCTAssertNotNil(audio)
    }
    
    func testChat() async throws {
        let response = try await client.chat(messages: [.init(role: "user", content: "Hello")], model: "test-model")
        XCTAssertNotNil(response)
    }
}
