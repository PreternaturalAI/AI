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
    public func listChats() async throws -> [HumeAI.Chat] {
        let response = try await run(\.listChats)
        
        return response.chats
    }
    
    public func listChatEvents(chatId: String) async throws -> [HumeAI.ChatEvent] {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: chatId
        )
        let response = try await run(\.listChatEvents, with: input)
        
        return response.events
    }
    
    public func getChatAudio(chatId: String) async throws -> Data {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: chatId
        )
        
        return try await run(\.getChatAudio, with: input)
    }
}
