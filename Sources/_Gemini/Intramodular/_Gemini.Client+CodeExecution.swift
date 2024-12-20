//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension _Gemini.Client {
    public func generateContentWithCodeExecution(
        messages: [_Gemini.Message],
        model: _Gemini.Model,
        toolConfig: _Gemini.ToolConfiguration? = nil,
        configuration: _Gemini.GenerationConfiguration? = nil
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
        
        let tool = _Gemini.Tool(codeExecutionEnabled: true)
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: model,
            requestBody: .init(
                contents: contents,
                generationConfig: configuration,
                tools: [tool],
                toolConfiguration: toolConfig,
                systemInstruction: systemInstruction
            )
        )
        
        let response = try await run(\.generateContent, with: input)
        
        let content = try _Gemini.Content(apiResponse: response)
                
        return content
    }
}
