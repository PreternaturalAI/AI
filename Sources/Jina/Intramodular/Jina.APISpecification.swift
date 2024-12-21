//
// Copyright (c) Preternatural AI, Inc.
//

import FoundationX
import NetworkKit
import Swallow

extension Jina {
    public enum APIError: APIErrorProtocol {
        public typealias API = Jina.APISpecification
        
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
            public var apiKey: String
        }
        
        public let configuration: Configuration
        
        public var host: URL  {
            URL(string: "https://api.jina.ai/v1/")!
        }
        
        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("embeddings")
        public var createEmbeddings = Endpoint<RequestBodies.CreateEmbedding, Jina.Embeddings, Void>()
    }
}

extension Jina.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<Jina.APISpecification, Input, Output, Options> {
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
                .header(.authorization(.bearer, configuration.apiKey))
        }
        
        struct _ErrorWrapper: Codable, Hashable, Sendable {
            struct Error: Codable, Hashable, Sendable {
                let detail: [ErrorDetail]
            }
            
            struct ErrorDetail: Codable, Hashable, Sendable {
                let loc: [String]
                let param: AnyCodable?
                let msg: String
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
                        if let errorMessage = error.detail.first?.msg {
                            if errorMessage.contains("You didn't provide an API key") {
                                throw Error.apiKeyMissing
                            } else if errorMessage.contains("Incorrect API key provided") {
                                throw Error.incorrectAPIKeyProvided
                            }
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

extension Jina.APISpecification {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
    
    public enum ResponseBodies: _StaticSwift.Namespace {
        
    }
}

extension Jina.APISpecification.RequestBodies {
    public struct CreateEmbedding: Codable, Hashable {
        public let model: Jina.Model
        public let input: [String]
        public let encodingFormat: [EncodingFormat]
        
        public enum EncodingFormat: String, Codable, Hashable, Sendable {
            case float
            case base64
            case binary
            case ubinary
        }
        
        init(
            model: Jina.Model,
            input: [String],
            encodingFormat: [EncodingFormat]?
        ) {
            self.model = model
            self.input = input
            self.encodingFormat = encodingFormat ?? [.float]
        }
    }
}
