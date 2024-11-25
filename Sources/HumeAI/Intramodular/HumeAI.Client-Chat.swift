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
        messages: [HumeAI.APISpecification.RequestBodies.ChatRequest.Message],
        model: String,
        temperature: Double? = nil
    ) async throws -> HumeAI.APISpecification.ResponseBodies.ChatResponse {
        let input = HumeAI.APISpecification.RequestBodies.ChatRequest(
            messages: messages,
            model: model,
            temperature: temperature,
            maxTokens: nil,
            stream: nil
        )
        return try await run(\.chat, with: input)
    }
}
