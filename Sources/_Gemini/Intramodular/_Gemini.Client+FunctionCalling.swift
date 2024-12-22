//
// Copyright (c) Preternatural AI, Inc.
//

extension _Gemini.Client {
    public func generateContentWithFunctions(
        messages: [_Gemini.Message],
        functions: [_Gemini.FunctionDefinition],
        model: _Gemini.Model,
        functionConfig: _Gemini.FunctionCallingConfiguration = .init(mode: .auto)
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
        
        let tool = _Gemini.Tool(functionDeclarations: functions)
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: model,
            requestBody: .init(
                contents: contents,
                tools: [tool],
                toolConfiguration: _Gemini.ToolConfiguration(functionCallingConfig: functionConfig),
                systemInstruction: systemInstruction
            )
        )
        
        let response = try await run(\.generateContent, with: input)
        
        return try _Gemini.Content(apiResponse: response)
    }
}
