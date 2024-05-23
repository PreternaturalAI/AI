//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import OpenAI
import XCTest

final class FunctionCallingTests: XCTestCase {
    let llm: any LLMRequestHandling = client
    
    func testFunctionCalling() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system {
                "You are a Metereologist Expert accurately giving weather data in fahrenheit at any given city around the world"
            },
            .user {
                "What is the weather in San Francisco, CA?"
            }
        ]
        
        let functionCall1: AbstractLLM.ChatFunctionCall = try await llm.complete(
            messages,
            functions: [makeGetWeatherFunction1()],
            as: .functionCall
        )
        
        let functionCall2: AbstractLLM.ChatFunctionCall = try await llm.complete(
            messages,
            functions: [makeGetWeatherFunction2()],
            as: .functionCall
        )
        
        let result1 = try functionCall1.decode(GetWeatherParameters.self)
        let result2 = try functionCall2.decode(GetWeatherParameters.self)
        
        print(result1, result2)
    }
    
    private func makeGetWeatherFunction1() -> AbstractLLM.ChatFunctionDefinition {
        let weatherObjectSchema = JSONSchema(
            type: .object,
            description: "Weather in a certain location",
            properties: [
                "location": JSONSchema(
                    type: .string,
                    description: "The city and state, e.g. San Francisco, CA"
                ),
                "unit_fahrenheit" : JSONSchema(
                    type: .number,
                    description: "The unit of temperature in 'fahrenheit'"
                )
            ],
            required: true
        )
        
        let getWeatherFunction: AbstractLLM.ChatFunctionDefinition = AbstractLLM.ChatFunctionDefinition(
            name: "get_weather",
            context: "Get the current weather in a given location",
            parameters: JSONSchema(
                type: .object,
                description: "Weather data for a given location in fahrenheit",
                properties: [
                    "weather": .array(weatherObjectSchema)
                ]
            )
        )
        
        return getWeatherFunction
    }
    
    struct GetWeatherParameters: Codable, Hashable, Sendable {
        let weather: [WeatherObject]
    }
    
    struct WeatherObject: Codable, Hashable, Sendable {
        let location: String
        let unit_fahrenheit: Double?
    }
    
    private func makeGetWeatherFunction2() throws -> AbstractLLM.ChatFunctionDefinition {
        let getWeatherFunction: AbstractLLM.ChatFunctionDefinition = AbstractLLM.ChatFunctionDefinition(
            name: "get_weather",
            context: "Get the current weather in a given location",
            parameters: JSONSchema(
                type: .object,
                description: "Weather data for a given location in fahrenheit",
                properties: [
                    "weather": try .array {
                        try JSONSchema(
                            type: WeatherObject.self,
                            description: "Weather in a certain location",
                            propertyDescriptions: [
                                "location": "The city and state, e.g. San Francisco, CA",
                                "unit_fahrenheit": "The unit of temperature in 'fahrenheit'"
                            ]
                        )
                    }
                ]
            )
        )
        
        return getWeatherFunction
    }
}

