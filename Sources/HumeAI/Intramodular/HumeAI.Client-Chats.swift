//
//  HumeAI.Client-Chats.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listChats() async throws -> [HumeAI.APISpecification.ResponseBodies.Chat] {
        let response = try await run(\.listChats)
        return response.chats
    }
    
    public func listChatEvents(chatId: String) async throws -> [HumeAI.APISpecification.ResponseBodies.ChatEvent] {
        let response = try await run(\.listChatEvents, with: chatId)
        return response.events
    }
    
    public func getChatAudio(chatId: String) async throws -> Data {
        try await run(\.getChatAudio, with: chatId)
    }
}
