//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swallow

extension Anthropic {
    public enum APIError: APIErrorProtocol {
        public typealias API = Anthropic.API
        
        case apiKeyMissing
        case incorrectAPIKeyProvided
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

extension Anthropic.API {
    public enum RequestBodies: _StaticNamespaceType {
        
    }
    
    public enum ResponseBodies: _StaticNamespaceType {
        
    }
}

extension Anthropic.API.RequestBodies {
    public struct Complete: Codable, Hashable, Sendable {
        public var prompt: String
        public var model: Anthropic.Model
        public var maxTokensToSample: Int
        public var stopSequences: [String]?
        public var stream: Bool?
        public var temperature: Double?
        public let topK: Int?
        public let topP: Double?
    }
}

extension Anthropic.API.ResponseBodies {
    public struct Complete: Codable, Hashable, Sendable {
        public enum StopReason: String, Codable, Hashable, Sendable {
            case stopSequence = "stop_sequence"
            case maxTokens = "max_tokens"
        }
        
        public var completion: String
        public let stopReason: StopReason
        public let stop: String?
    }
}
