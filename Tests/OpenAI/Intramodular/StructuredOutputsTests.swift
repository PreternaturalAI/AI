//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import OpenAI
import XCTest

final class StructuredOutputTests: XCTestCase {
    let llm: OpenAI.Client = client
    
    public struct CalendarEvent: Codable {
        public let name: String
        public let date: String
        public let participants: [String]
    }
    
    let calendarEventSchema = JSONSchema(
        type: .object,
        description: "A calendar event.",
        properties: [
            "name": JSONSchema(
                type: .string,
                description: "The name of the calendar event."
            ),
            "date": JSONSchema(
                type: .string,
                description: "The date of the calendar event."
            ),
            "participants": JSONSchema.array(
                JSONSchema(type: .string, description: "An identified participant of the calendar event.")
            )
        ],
        required: true
    )

    func testExtractingCalendarEvent() async throws {
        let parameters = OpenAI.Client.ChatCompletionParameters(
            responseFormat: OpenAI.ChatCompletion.ResponseFormat(
                schema: calendarEventSchema,
                name: "CalendarEvent",
                strict: false
            )
        )
        
        let messages: [OpenAI.ChatMessage] = [
            .system(
                """
                You are a highly intelligent system that converts unstructured text to structured data. Extract the event information.
                """
            ),
            .user("Alice and Bob are going to a science fair on Friday.")
        ]

        let completion: OpenAI.ChatCompletion = try await client.createChatCompletion(
            messages: messages,
            model: .gpt_4o,
            parameters: parameters
        )
        
        let jsonString: String = try completion.choices.first.unwrap().message.body.plainText
        
        let event: CalendarEvent = try JSONDecoder().decode(CalendarEvent.self, from: jsonString.data(using: .utf8).unwrap())
        
        XCTAssertEqual(Set(event.participants), ["Alice", "Bob"])
        XCTAssertEqual(event.name.lowercased(), "science fair")
    }
}

/*@JSONSchemaConvertible
 public struct CalendarEvent {
 public let name: String
 public let date: String
 public let participants: [String]
 }*/


/*
 final class FunctonCallingVersusStructuredOutputsTestCase: XCTestCase {
 let llm: OpenAI.APIClient = client
 
 struct BingSearchQuery {
 let text: String
 }
 
 struct GoogleSearchQuery {
 let text: String
 }
 
 func test() {
 let message = OpenAI.ChatCompletionParameters
 llm.completion(for: <#T##AbstractLLM.ChatPrompt#>)
 }
 }
 

 */
