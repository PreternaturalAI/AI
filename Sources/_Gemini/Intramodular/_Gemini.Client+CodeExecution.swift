//
//  _Gemini.Client+CodeExecution.swift
//  AI
//
//  Created by Jared Davidson on 12/13/24.
//

import Foundation

extension _Gemini.Client {
    public func generateContentWithCodeExecution(
        messages: [_Gemini.Message],
        model: _Gemini.Model
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
        
        let tool = _Gemini.APISpecification.RequestBodies.Tool(codeExecutionEnabled: true)
        
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
        
        let content = try _Gemini.Content(apiResponse: response)
        
        for part in content.parts {
            switch part {
                case .text(let string):
                    break
                case .functionCall(let functionCall):
                    break
                case .executableCode(let language, let code):
                    print(language, code)
                case .codeExecutionResult(let outcome, let output):
                    break
            }
        }
        
        return content
    }
}
