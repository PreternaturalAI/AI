//
//  _GeminiFunctionTests.swift
//  AI
//
//  Created by Jared Davidson on 12/13/24.
//


import Testing
import Foundation
import _Gemini
import AI

@Suite struct _GeminiFunctionTests {
    @Test func testLightingSystem() async throws {
        let messages = [
            _Gemini.Message(
                role: .system,
                content: "You are a helpful lighting system bot. You can turn lights on and off, and you can set the color. Do not perform any other tasks."
            ),
            _Gemini.Message(
                role: .user,
                content: "Turn on the lights and set them to red."
            )
        ]
        
        let functions = [
            _Gemini.FunctionDefinition(
                name: "enable_lights",
                description: "Turn on the lighting system.",
                parameters: _Gemini.ParameterSchema(
                    type: "object",
                    properties: [
                        "dummy": _Gemini.ParameterSchema(
                            type: "string",
                            description: "Placeholder parameter"
                        )
                    ]
                )
            ),
            _Gemini.FunctionDefinition(
                name: "set_light_color",
                description: "Set the light color. Lights must be enabled for this to work.",
                parameters: _Gemini.ParameterSchema(
                    type: "object",
                    properties: [
                        "rgb_hex": _Gemini.ParameterSchema(
                            type: "string",
                            description: "The light color as a 6-digit hex string, e.g. ff0000 for red."
                        )
                    ],
                    required: ["rgb_hex"]
                )
            ),
            _Gemini.FunctionDefinition(
                name: "stop_lights",
                description: "Turn off the lighting system.",
                parameters: _Gemini.ParameterSchema(
                    type: "object",
                    properties: [
                        "dummy": _Gemini.ParameterSchema(
                            type: "string",
                            description: "Placeholder parameter"
                        )
                    ]
                )
            )
        ]
        
        let functionCalls = try await client.generateContentWithFunctions(
            messages: messages,
            functions: functions,
            model: .gemini_1_5_pro_latest
        )
        
        print(functionCalls)
        
        #expect(!functionCalls.isEmpty, "No function calls returned")
        
        guard let lastFunctionCall = functionCalls.last?.args else {
            #expect(false, "No function call arguments found")
            return
        }
        
        struct LightingCommandParameters: Codable {
            let rgbHex: String?
        }
        
        let result = try JSONSerialization.data(withJSONObject: lastFunctionCall)
            .decode(LightingCommandParameters.self)
        
        #expect(result.rgbHex != nil, "Light color parameter should not be nil")
    }
}
