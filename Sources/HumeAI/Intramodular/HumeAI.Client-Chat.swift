//
//  HumeAI.Client-Chat.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.Client {
    public func chat(
        messages: [HumeAI.ChatMessage],
        model: String,
        temperature: Double? = nil
    ) async throws -> HumeAI.ChatResponse {
        let input = HumeAI.APISpecification.RequestBodies.ChatRequest(
            messages: messages.map { .init(role: $0.role, content: $0.content) },
            model: model,
            temperature: temperature,
            maxTokens: nil,
            stream: nil
        )
        return try await run(\.chat, with: input)
    }
}
