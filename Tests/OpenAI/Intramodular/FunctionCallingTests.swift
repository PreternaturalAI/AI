//
// Copyright (c) Preternatural AI, Inc.
//

import AI
import CorePersistence
import OpenAI
import XCTest

final class FunctionCallingTests: XCTestCase {
    private let llm: any LLMRequestHandling = client
    private let model: OpenAI.Model = .gpt_3_5
    
    let bookRestaurantFunction = AbstractLLM.ChatFunctionDefinition(
        name: "book_restaurant",
        context: "Make a restaurant booking",
        parameters: JSONSchema(
            type: .object,
            description: "Required data to make a restaurant booking",
            properties: [
                "restaurant_name": JSONSchema(
                    type: .string,
                    description: "The name of the restaurant",
                    required: false
                ),
                "reservation_date" : JSONSchema(
                    type: .string,
                    description: "The date of the restaurant booking in yyyy-MM-dd format. Should be a date with a year, month, day. NOTHING ELSE",
                    required: false
                ),
                "reservation_time" : JSONSchema(
                    type: .string,
                    description: "The time of the reservation in HH:mm format. Should include hours and minutes. NOTHING ELSE",
                    required: false
                ),
                "number_of_guests" : JSONSchema(
                    type: .integer,
                    description: "The total number of people the reservation is for",
                    required: false
                )
            ],
            required: false
        )
    )
    
    func testFunctionCalling() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system(systemMessageAllowNullParameters),
            .user("I'd like to book La Tratoria for 4 people tomorrow")
        ]
        
        do {
            let functionCall: AbstractLLM.ChatFunctionCall = try await client.complete(
                messages,
                functions: [bookRestaurantFunction],
                model: model,
                as: .functionCall
            )
            
            let parameters = try functionCall.decode(BookRestaurantFunctionParameters.self)
            
            XCTAssertNotNil(parameters.restaurantName)
            XCTAssertEqual(parameters.restaurantName, "La Tratoria")
            XCTAssertNotNil(parameters.reservationDate)
            XCTAssertNil(parameters.reservationTime)
            XCTAssertNotNil(parameters.numberOfGuests)
            XCTAssertEqual(parameters.numberOfGuests, 4)
            
        } catch {
            runtimeIssue(error)
        }
    }
    
    func testFunctionCallOrMessageWithMessageResponse() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system(systemMessageAllParametersRequired),
            .user("I'd like to book La Tratoria for 4 people tomorrow")
        ]
        
        do {
            let functionCallOrMessage: Either<AbstractLLM.ChatFunctionCall, AbstractLLM.ChatMessage> = try await client.complete(
                messages,
                functions: [
                    bookRestaurantFunctionWithAllParametersMandatory
                ],
                model: model,
                as: .either(.functionCall, or: .chatMessage)
            )
            
            switch functionCallOrMessage {
            case .left(let functionCall):
                XCTFail("Expected .right case but got .left with function call: \(functionCall)")
            case .right(let message):
                let messageText = try String(message)
                XCTAssertTrue(messageText.lowercased().contains("time of the reservation"), "Message should point out that 'time of the reservation' is missing but got: \(messageText)")
            }
        }
    }
    
    func testFunctionCallOrMessageWithFunctionCallResponse() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system(systemMessageAllParametersRequired),
            .user("I'd like to book La Tratoria for 4 people tomorrow at 5pm")
        ]
        
        do {
            let functionCallOrMessage: Either<AbstractLLM.ChatFunctionCall, AbstractLLM.ChatMessage> = try await client.complete(
                messages,
                functions: [
                    bookRestaurantFunctionWithAllParametersMandatory
                ],
                model: model,
                as: .either(.functionCall, or: .chatMessage)
            )
            
            switch functionCallOrMessage {
            case .left(let functionCall):
                let parameters = try functionCall.decode(BookRestaurantFunctionParameters.self)

                XCTAssertNotNil(parameters.restaurantName)
                XCTAssertEqual(parameters.restaurantName, "La Tratoria")
                XCTAssertNotNil(parameters.reservationDate)
                XCTAssertNotNil(parameters.reservationTime)
                XCTAssertEqual(parameters.reservationTime, "17:00")
                XCTAssertNotNil(parameters.numberOfGuests)
                XCTAssertEqual(parameters.numberOfGuests, 4)
            case .right(let message):
                let messageText = try String(message)
                XCTFail("Expected .left case but got .right with message: \(messageText)")
            }
        }
    }
    
    func testFunctionCallingTwoFunctionsWithInvalidRequest() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system(systemMessageTwoFunctions),
            .user("Tell me a joke")
        ]
        
        do {
            let functions: [AbstractLLM.ChatFunctionDefinition] = [
                bookRestaurantFunctionWithAllParametersMandatory,
                try RejectInvalidUserQueryFunction.toChatFunctionDefinition()
            ]
            
            let functionCallOrMessage: Either<AbstractLLM.ChatFunctionCall, AbstractLLM.ChatMessage> = try await client.complete(
                messages,
                functions: functions,
                model: model,
                as: .either(.functionCall, or: .chatMessage)
            )
            
            switch functionCallOrMessage {
            case .left(let functionCall):
                if functionCall.name == RejectInvalidUserQueryFunction.name {
                    let result: RejectInvalidUserQueryFunction.Parameters = try functionCall.decode(RejectInvalidUserQueryFunction.Parameters.self)
                    
                    XCTAssertNotNil(result.reason_for_rejection)
                    print(result.reason_for_rejection)
                                        
                } else {
                    let result = try functionCall.decode(BookRestaurantFunctionParameters.self)
                    
                    XCTFail("Expected the reject_valid_intent function to be called. Instead got \(result)")
                }
            case .right(let message):
                let messageText = try String(message)
                
                XCTFail("Expected the reject_valid_intent function to be called. Instead got \(messageText)")
            }
        }
    }
    
    func testFunctionCallingTwoFunctionsWithValidRequest() async throws {
        let messages: [AbstractLLM.ChatMessage] = [
            .system(systemMessageTwoFunctions),
            .user("I'd like to book La Tratoria for 4 people tomorrow at 5pm")
        ]
        
        do {
            let functions: [AbstractLLM.ChatFunctionDefinition] = [
                bookRestaurantFunctionWithAllParametersMandatory,
                try RejectInvalidUserQueryFunction.toChatFunctionDefinition()
            ]
            
            let functionCallOrMessage: Either<AbstractLLM.ChatFunctionCall, AbstractLLM.ChatMessage> = try await client.complete(
                messages,
                functions: functions,
                model: model,
                as: .either(.functionCall, or: .chatMessage)
            )
            
            switch functionCallOrMessage {
            case .left(let functionCall):
                if functionCall.name == RejectInvalidUserQueryFunction.name {
                    let result: RejectInvalidUserQueryFunction.Parameters = try functionCall.decode(RejectInvalidUserQueryFunction.Parameters.self)
                    
                    XCTFail("Expected the book_restaurant function to be called. Instead got \(result)")
                                        
                } else {
                    let parameters = try functionCall.decode(BookRestaurantFunctionParameters.self)

                    XCTAssertNotNil(parameters.restaurantName)
                    XCTAssertEqual(parameters.restaurantName, "La Tratoria")
                    XCTAssertNotNil(parameters.reservationDate)
                    XCTAssertNotNil(parameters.reservationTime)
                    XCTAssertEqual(parameters.reservationTime, "17:00")
                    XCTAssertNotNil(parameters.numberOfGuests)
                    XCTAssertEqual(parameters.numberOfGuests, 4)
                }
            case .right(let message):
                let messageText = try String(message)
                
                XCTFail("Expected the reject_valid_intent function to be called. Instead got \(messageText)")
            }
        }
    }
}

// book_restaurant function definition
extension FunctionCallingTests {
    
    struct BookRestaurantFunctionParameters: Codable, Hashable, Sendable {
        var restaurantName: String?
        var reservationDate: String?
        var reservationTime: String?
        var numberOfGuests: Int?
    }
    
    var systemMessageAllowNullParameters: PromptLiteral {
        """
        You are a helpful assistant tasked with booking restaurant reservations. 
        
        Please gather the following details efficiently:
        1. Name of the restaurant
        2. Date of the reservation
        3. Time of the reservation
        4. Number of people attending.
        
        Rules for calling `book_restaurant`:
        1. If the user doesn't provide a piece of information, simple pass NULL for that parameter. 
        2. If the user doesn't provide any information, pass NULL for all parameters.
        3. Pass NULL for parameters that you don't have the information for. 
        
        Always call `book_restaurant`.
        
        DO NOT ADD ANY ADDITIONAL INFORMATION. 
        
        Today's date is \(Date().mediumStyleDateString)
        """
    }
    
    var systemMessageAllParametersRequired: PromptLiteral {
        """
        You are a helpful assistant tasked with booking restaurant reservations. 
        
        Please gather the following details efficiently:
        1. Name of the restaurant
        2. Date of the reservation
        3. Time of the reservation
        4. Number of people attending.
        
        Call the 'book_restaurant' function once ALL the restaurant booking details have been gathered.
        
        Today's date is \(Date().mediumStyleDateString)
        """
    }
    
    var bookRestaurantFunctionWithAllParametersMandatory: AbstractLLM.ChatFunctionDefinition {
        var function = bookRestaurantFunction
        
        function.parameters.disableAdditionalPropertiesRecursively()
        
        return function
    }
}

// reject_invalid_user_query function definition
extension FunctionCallingTests {
    
    var systemMessageTwoFunctions: PromptLiteral {
        """
        You are a helpful assistant tasked with booking restaurant reservations. 
        
        Please gather the following details efficiently:
        1. Name of the restaurant
        2. Date of the reservation
        3. Time of the reservation
        4. Number of people attending.
        
        Call the 'book_restaurant' function once ALL the restaurant booking details have been gathered.
        
        Today's date is \(Date().mediumStyleDateString)
        
        If the user asks something that is out-of-scope of restaurant booking, call \(RejectInvalidUserQueryFunction.name) appropriately. Do not call `book_restaurant` in that case.
        """
    }
    
    struct RejectInvalidUserQueryFunction {
        
        struct Parameters: Codable, Hashable, Initiable, Sendable {
            @JSONSchemaDescription("The reason the user's message has been flagged as an invalid intent.")
            var reason_for_rejection: String
            
            @JSONSchemaDescription("The category of the invalid intent parsed from the user's message.")
            var invalid_intent_category: String?
            
            init() {
                
            }
        }
        
        static var name: AbstractLLM.ChatFunction.Name {
            "reject_invalid_user_query"
        }
        
        static var context: String {
            """
            Call this function to report an invalid user query. Reject any user queries that don't pertain to restaurant booking.
            """
        }
        
        static func toChatFunctionDefinition() throws -> AbstractLLM.ChatFunctionDefinition {
            AbstractLLM.ChatFunctionDefinition(
                name: name,
                context: context,
                parameters: try JSONSchema(reflecting: Parameters.self)
            )
        }
    }
}

extension Date {
    
    var mediumStyleDateString: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        return dateFormatter.string(from: self)
    }
    
}

