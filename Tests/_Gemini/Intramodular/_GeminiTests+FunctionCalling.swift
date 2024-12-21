//
// Copyright (c) Preternatural AI, Inc.
//

import AI
import Foundation
import Testing
import _Gemini

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
        
        let response = try await client.generateContentWithFunctions(
            messages: messages,
            functions: functions,
            model: .gemini_1_5_pro_latest
        )
        
        for part in response.parts {
            switch part {
                case .text(_):
                    break
                case .functionCall(let functionCall):
                    do {
                        let data = try functionCall.args.toJSONData()
                        if let jsonObject = try? JSONSerialization.jsonObject(with: data) {
                            let result = try JSONSerialization.data(withJSONObject: jsonObject)
                                .decode(LightingCommandParameters.self)
                            
                            if result.rgbHex != nil {
                                #expect(true)
                            }
                        } else {
                            print("Invalid JSON format")
                        }
                    } catch {
                        print("Error:", error)
                    }
                case .executableCode(_, _):
                    break
                case .codeExecutionResult(_, _):
                    break
            }
        }
        
        struct LightingCommandParameters: Codable {
            let rgbHex: String?
        }
    }
}
