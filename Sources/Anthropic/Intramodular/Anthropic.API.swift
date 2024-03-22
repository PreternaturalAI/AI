//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import NetworkKit
import Swallow

extension Anthropic {
    public enum APIError: APIErrorProtocol {
        public typealias API = Anthropic.API
        
        case apiKeyMissing
        case invalidAPIKey
        case rateLimitExceeded
        case badRequest(API.Request.Error)
        case runtime(AnyError)
        
        public var traits: ErrorTraits {
            [.domain(.networking)]
        }
    }

    public struct API: RESTAPISpecification {
        public typealias Error = APIError

        public struct Configuration: Codable, Hashable {
            public var apiKey: String?
        }

        public let configuration: Configuration

        public var host: URL  {
            URL(string: "https://api.anthropic.com/v1/")!
        }

        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("complete")
        public var complete = Endpoint<RequestBodies.Complete, ResponseBodies.Complete, Void>()
        
        @POST
        @Path("messages")
        public var createMessage = Endpoint<Anthropic.API.RequestBodies.CreateMessage, ResponseBodies.CreateMessage, Void>()
    }
}

extension Anthropic.API {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<Anthropic.API, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            let configuration = context.root.configuration
            
            return try super
                .buildRequestBase(from: input, context: context)
                .jsonBody(input, keyEncodingStrategy: .convertToSnakeCase)
                .header(.custom(key: "anthropic-version", value: "2023-06-01"))
                .header(.custom(key: "x-api-key", value: configuration.apiKey))
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
                        print(error.message)
                        
                        if error.message.contains("x-api-key header is required") {
                            throw Error.apiKeyMissing
                        } else if error.message.contains("invalid x-api-key") {
                            throw Error.invalidAPIKey
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

extension Anthropic.API {
    public enum RequestBodies: _StaticNamespaceType {
        
    }
    
    public enum ResponseBodies: _StaticNamespaceType {
        
    }
}

extension Anthropic.API.RequestBodies {
    public struct CreateMessage: Codable {
        public enum CodingKeys: String, CodingKey {
            case model
            case messages
            case system
            case maxTokens = "max_tokens"
            case temperature
            case topP = "top_p"
            case topK = "top_k"
            case stopSequences = "stop_sequences"
            case stream
            case metadata
        }

        public var model: Anthropic.Model
        public var messages: [Anthropic.ChatMessage]
        public var system: String?
        public var maxTokens: Int
        public var temperature: Double?
        public var topP: Double?
        public var topK: UInt?
        public var stopSequences: [String]?
        public var stream: Bool?
        public var metadata: Metadata?
                
        public struct Metadata: Codable, Hashable, Sendable {
            public enum CodingKeys: String, CodingKey {
                case userID = "user_id"
            }

            public var userID: String
            
            public init(userID: String) {
                self.userID = userID
            }
        }
                
        public init(
            model: Anthropic.Model,
            messages: [Anthropic.ChatMessage],
            system: String?,
            maxTokens: Int,
            temperature: Double?,
            topP: Double?,
            topK: UInt?,
            stopSequences: [String]?,
            stream: Bool? ,
            metadata: Metadata?
        ) {
            self.model = model
            self.messages = messages
            self.system = system
            self.maxTokens = maxTokens
            self.temperature = temperature
            self.topP = topP
            self.topK = topK
            self.stopSequences = stopSequences
            self.stream = stream
            self.metadata = metadata
        }
    }
    public struct Complete: Codable, Hashable, Sendable {
        public var prompt: String
        public var model: Anthropic.Model
        public var maxTokensToSample: Int
        public var stopSequences: [String]?
        public var stream: Bool?
        public var temperature: Double?
        public var topK: Int?
        public var topP: Double?
        
        public init(
            prompt: String,
            model: Anthropic.Model,
            maxTokensToSample: Int,
            stopSequences: [String]?,
            stream: Bool?,
            temperature: Double?,
            topK: Int?,
            topP: Double?
        ) {
            self.prompt = prompt
            self.model = model
            self.maxTokensToSample = maxTokensToSample
            self.stopSequences = stopSequences
            self.stream = stream
            self.temperature = temperature
            self.topK = topK
            self.topP = topP
        }
    }
}

extension Anthropic.API.ResponseBodies {
    public struct Complete: Codable, Hashable, Sendable {
        public enum StopReason: String, Codable, Hashable, Sendable {
            case maxTokens = "max_tokens"
            case stopSequence = "stop_sequence"
        }
        
        public var completion: String
        public let stopReason: StopReason
        public let stop: String?
    }
    
    public struct CreateMessage: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case id
            case model
            case type
            case role
            case content
            case stopReason
            case stopSequence
            case usage
        }

        public enum StopReason: String, Codable, Hashable, Sendable {
            case endTurn = "end_turn"
            case maxTokens = "max_tokens"
            case stopSequence = "stop_sequence"
            
            public func __conversion() -> AbstractLLM.ChatCompletion.StopReason {
                switch self {
                    case .endTurn:
                        return .endTurn
                    case .maxTokens:
                        return .maxTokens
                    case .stopSequence:
                        return .stopSequence
                }
            }
        }

        public let id: String
        public let model: Anthropic.Model
        public let type: String?
        public let role: Anthropic.ChatMessage.Role
        public let content: [Content]
        public let stopReason: StopReason?
        public let stopSequence: String?
        public let usage: Usage
        
        public enum ContentType: String, Codable, Hashable, Sendable {
            case image // FIXME: Unimplemented
            case text
        }

        public struct Content: Codable, Hashable, Sendable {
            public let type: ContentType
            public let text: String
        }
        
        public struct Usage: Codable, Hashable, Sendable {
            public let inputTokens: Int
            public let outputTokens: Int
        }
    }
    
    public struct CreateMessageStream: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case type
            case index
            case message
            case delta
            case contentBlock
        }

        public struct Delta: Codable, Hashable, Sendable {
            public let type: String?
            public let text: String?
            public let stopReason: String?
            public let stopSequence: String?
        }

        public let type: String
        public let index: Int?
        public let message: CreateMessage?
        public let delta: Delta?
        public let contentBlock: Delta?
    }
}
