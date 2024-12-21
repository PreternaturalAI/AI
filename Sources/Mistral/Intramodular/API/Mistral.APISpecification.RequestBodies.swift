//
// Copyright (c) Preternatural AI, Inc.
//

import FoundationX
import NetworkKit
import Swallow

extension Mistral {
    public enum APIError: APIErrorProtocol {
        public typealias API = Mistral.APISpecification
        
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
            URL(string: "https://api.mistral.ai/v1/")!
        }
        
        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("chat/completions")
        public var chatCompletions = Endpoint<RequestBodies.ChatCompletions, ResponseBodies.ChatCompletion, Void>()
        
        @POST
        @Path("embeddings")
        public var createEmbeddings = Endpoint<RequestBodies.CreateEmbedding, Mistral.Embeddings, Void>()
    }
}

extension Mistral.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<Mistral.APISpecification, Input, Output, Options> {
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

extension Mistral.APISpecification {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
    
    public enum ResponseBodies: _StaticSwift.Namespace {
        
    }
}

extension Mistral.APISpecification.RequestBodies {
    /// https://docs.mistral.ai/api#operation/createChatCompletion
    public struct ChatCompletions: Codable, Hashable, Sendable {
        public var model: Mistral.Model
        public var messages: [Mistral.ChatMessage]
        public var temperature: Double?
        public var topP: Double?
        public var maxTokens: Int?
        public var stream: Bool?
        public var randomSeed: Int?
    }
}

extension Mistral.APISpecification.RequestBodies {
    public struct CreateEmbedding: Codable, Hashable {
        public let model: Mistral.Model
        public let input: [String]
        public let encodingFormat: String
        
        init(input: [String]) {
            self.model = Mistral.Model.mistral_embed
            self.input = input
            self.encodingFormat = "Float"
        }
    }
}


