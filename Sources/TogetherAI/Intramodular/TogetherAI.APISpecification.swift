//
// Copyright (c) Preternatural AI, Inc.
//

import FoundationX
import NetworkKit
import Swallow

extension TogetherAI {
    public enum APIError: APIErrorProtocol {
        public typealias API = TogetherAI.APISpecification
        
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
            URL(string: "https://api.together.xyz/v1/")!
        }
        
        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("embeddings")
        public var createEmbeddings = Endpoint<RequestBodies.CreateEmbedding, TogetherAI.Embeddings, Void>()
    }
}

extension TogetherAI.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<TogetherAI.APISpecification, Input, Output, Options> {
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
                let detail: String
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
                        if error.detail.contains("You didn't provide an API key") {
                            throw Error.apiKeyMissing
                        } else if error.detail.contains("Incorrect API key provided") {
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

extension TogetherAI.APISpecification {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
    
    public enum ResponseBodies: _StaticSwift.Namespace {
        
    }
}

extension TogetherAI.APISpecification.RequestBodies {
    public struct CreateEmbedding: Codable, Hashable {
        public let model: TogetherAI.Model
        public let input: String
    }
}
