//
//  HumeAI.Client.ChatGroup.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func listChatGroups() async throws -> [HumeAI.APISpecification.ResponseBodies.ChatGroup] {
        let response = try await run(\.listChatGroups)
        return response.chatGroups
    }
    
    public func getChatGroup(id: String) async throws -> HumeAI.APISpecification.ResponseBodies.ChatGroup {
        try await run(\.getChatGroup, with: id)
    }
}
