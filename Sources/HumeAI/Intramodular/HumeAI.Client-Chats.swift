//
// Copyright (c) Preternatural AI, Inc.
//

import Merge
import NetworkKit
import SwiftAPI

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
