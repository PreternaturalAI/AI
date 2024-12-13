//
//  _Gemini.Client+FunctionCalling.swift
//  AI
//
//  Created by Jared Davidson on 12/13/24.
//

extension _Gemini.Client {
    public func generateContentWithFunctions(
        messages: [_Gemini.Message],
        functions: [_Gemini.FunctionDefinition],
        model: _Gemini.Model,
        functionConfig: _Gemini.FunctionCallingConfig = .init(mode: .auto)
    ) async throws -> [_Gemini.FunctionCall] {
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
        
        let tool = _Gemini.APISpecification.RequestBodies.Tool(functionDeclarations: functions)
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: model,
            requestBody: .init(
                contents: contents,
                tools: [tool],
                toolConfig: _Gemini.ToolConfig(functionCallingConfig: functionConfig),
                systemInstruction: systemInstruction
            )
        )
        
        let response = try await run(\.generateContent, with: input)
        
        return response.candidates?.first?.content?.parts?.compactMap { part in
            if case let .functionCall(call) = part {
                return call
            }
            return nil
        } ?? []
    }
}
