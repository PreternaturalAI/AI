//
// Copyright (c) Preternatural AI, Inc.
//

import Merge
import NetworkKit
import SwiftAPI

extension HumeAI.Client {
    public func listChatGroups() async throws -> [HumeAI.ChatGroup] {
        let response = try await run(\.listChatGroups)
        
        return response.chatGroups.map { chatGroup in
            HumeAI.ChatGroup(
                id: chatGroup.id,
                name: chatGroup.name,
                createdOn: chatGroup.createdOn,
                modifiedOn: chatGroup.modifiedOn,
                chats: chatGroup.chats?.compactMap { chat in
                        HumeAI.Chat(
                            id: chat.id,
                            name: chat.name,
                            createdOn: chat.createdOn,
                            modifiedOn: chat.modifiedOn
                        )
                }
            )
        }
    }
    
    public func getChatGroup(id: String) async throws -> HumeAI.ChatGroup {
        let input = HumeAI.APISpecification.PathInput.ID(
            id: id
        )
        
        return try await run(\.getChatGroup, with: input)
    }
}
