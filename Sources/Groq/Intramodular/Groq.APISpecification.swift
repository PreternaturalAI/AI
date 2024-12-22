//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import FoundationX
import Swallow

extension Groq {
    public enum APIError: APIErrorProtocol {
        public typealias API = Groq.APISpecification
        
        case apiKeyMissing
        case incorrectAPIKeyProvided
        case rateLimitExceeded
        case badRequest(request: API.Request?, error: API.Request.Error)
        case runtime(AnyError)
        
        public var traits: ErrorTraits {
            [.domain(.networking)]
        }
    }
    
    public struct APISpecification: RESTAPISpecification {
        public typealias Error = APIError
        
        public struct Configuration: Codable, Hashable {
            public var apiKey: String?
        }
        
        public let configuration: Configuration
        
        public var host: URL  {
            URL(string: "https://api.groq.com/openai/v1/")!
        }
        
        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("chat/completions")
        var chatCompletions = Endpoint<RequestBodies.ChatCompletions, ResponseBodies.ChatCompletion, Void>()
    }
}

extension Groq.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<Groq.APISpecification, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            let configuration = context.root.configuration
            
            return try super
                .buildRequestBase(from: input, context: context)
                .jsonBody(input, keyEncodingStrategy: .convertToSnakeCase)
                .header(.contentType(.json))
                .header(.accept(.json))
                .header(.authorization(.bearer, configuration.apiKey.unwrap()))
        }
        
        struct _ErrorWrapper: Codable, Hashable, Sendable {
            struct Error: Codable, Hashable, Sendable {
                let type: String
                let param: AnyCodable?
                let message: String
            }
            
            let error: Error
        }
        
        override public func decodeOutputBase(
            from response: Request.Response,
            context: DecodeOutputContext
        ) throws -> Output {
            do {
                try response.validate()
            } catch {
                let apiError: Error
                
                if let error = error as? Request.Error {
                    if let error = try? response.decode(
                        _ErrorWrapper.self,
                        keyDecodingStrategy: .convertFromSnakeCase
                    ).error {
                        if error.message.contains("You didn't provide an API key") {
                            throw Error.apiKeyMissing
                        } else if error.message.contains("Incorrect API key provided") {
                            throw Error.incorrectAPIKeyProvided
                        }
                    }
                    
                    if response.statusCode.rawValue == 429 {
                        apiError = .rateLimitExceeded
                    } else {
                        apiError = .badRequest(error)
                    }
                } else {
                    apiError = .runtime(error)
                }
                
                throw apiError
            }
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
}

extension Groq.APISpecification {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
    
    public enum ResponseBodies: _StaticSwift.Namespace {
        
    }
}

extension Groq {
    public struct ChatMessage: Codable, Hashable, Sendable {
        public enum Role: String, Codable, Hashable, Sendable {
            case system
            case user
            case assistant
        }
        
        public var role: Role
        public var content: String
        
        public init(role: Role, content: String) {
            self.role = role
            self.content = content
        }
    }
}

extension Groq.APISpecification.RequestBodies {
    /// https://console.groq.com/docs/api-reference#chat-create
    struct ChatCompletions: Codable, Hashable, Sendable {
        var model: Groq.Model
        var messages: [Groq.ChatMessage]
        var temperature: Double?
        var topP: Double?
        var maxTokens: Int?
        var stream: Bool?
        var randomSeed: Int?
    }
}

extension Groq.APISpecification.ResponseBodies {
    public struct ChatCompletion: Codable, Hashable, Sendable {
        public struct Choice: Codable, Hashable, Sendable {
            public enum FinishReason: String, Codable, Hashable, Sendable {
                case stop = "stop"
                case length = "length"
                case modelLength = "model_length"
            }

            public let index: Int
            public let message: Groq.ChatMessage
            public let finishReason: FinishReason
        }
        
        public struct Usage: Codable, Hashable, Sendable {
            public let promptTokens: Int
            public let completionTokens: Int
            public let totalTokens: Int
        }
        
        public var id: String
        public var object: String
        public var created: Date
        public var model: String
        public var choices: [Choice]
        public let usage: Usage
    }
}
