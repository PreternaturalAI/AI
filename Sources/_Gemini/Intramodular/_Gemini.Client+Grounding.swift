//
//  _Gemini.Client+Grounding.swift
//  AI
//
//  Created by Jared Davidson on 12/13/24.
//

extension _Gemini.Client {
    public func generateContentWithGrounding(
        messages: [_Gemini.Message],
        model: _Gemini.Model,
        dynamicThreshold: Double = 0.3
    ) async throws -> _Gemini.Content {
        let contents = messages.filter { $0.role != .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        }
        
        let systemInstruction = messages.first { $0.role == .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        }
        
        let tool = _Gemini.Tool(
            googleSearchRetrieval: .init(
                dynamicRetrievalConfig: .init(
                    mode: "MODE_DYNAMIC",
                    dynamicThreshold: dynamicThreshold
                )
            )
        )
        
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: model,
            requestBody: .init(
                contents: contents,
                tools: [tool],
                toolConfig: nil,
                systemInstruction: systemInstruction
            )
        )
        
        let response = try await run(\.generateContent, with: input)
        return try _Gemini.Content(apiResponse: response)
    }
}
