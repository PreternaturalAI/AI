//
// Copyright (c) Vatsal Manot
//

import CorePersistence
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
        
        public struct Configuration: _RESTAPIConfiguration {
            public var apiKey: APIKey?
            
            public init(apiKey: APIKey? = nil) {
                self.apiKey = apiKey
            }
            
            public init(apiKey: String?) {
                self.apiKey = apiKey.map({ APIKey(serverURL: nil, value: $0) })
            }
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
                .header("anthropic-version", "2023-06-01")
                .header("anthropic-beta", "tools-2024-04-04")
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
    public enum ResponseBodies: _StaticSwift.Namespace {
        struct ErrorWrapper: Codable, Swift.Error, Hashable, Sendable {
            enum _Type: String, Codable, Hashable, Sendable {
                case type = "error"
            }
            
            let type: _Type
            let error: Error
            
            public struct Error: Swift.Error, Codable, Hashable, Sendable {
                public enum ErrorType: String, Codable, Hashable, Sendable {
                    case invalidAPIKey = "authentication_error"
                    case invalidRequestError = "invalid_request_error"
                    case overloaded = "overloaded_error"
                }
                
                public let type: ErrorType
                public let message: String
            }
        }
    }
}
