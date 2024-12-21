//
// Copyright (c) Preternatural AI, Inc.
//

import FoundationX
import NetworkKit
import Swallow

extension VoyageAI {
    public enum APIError: APIErrorProtocol {
        public typealias API = VoyageAI.APISpecification
        
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
            URL(string: "https://api.voyageai.com/v1/")!
        }
        
        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("embeddings")
        public var createEmbeddings = Endpoint<RequestBodies.CreateEmbedding, VoyageAI.Embeddings, Void>()
    }
}

extension VoyageAI.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<VoyageAI.APISpecification, Input, Output, Options> {
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

extension VoyageAI.APISpecification {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
    
    public enum ResponseBodies: _StaticSwift.Namespace {
        
    }
}

extension VoyageAI.APISpecification.RequestBodies {
    public struct CreateEmbedding: Codable, Hashable {
        
        /// Name of the model. Recommended options: voyage-2, voyage-large-2, voyage-finance-2, voyage-multilingual-2, voyage-law-2, voyage-code-2.
        public let model: VoyageAI.Model
        
        /// A single text string, or a list of texts as a list of strings. Currently, we have two constraints on the list:
        /// The maximum length of the list is 128.
        /// The total number of tokens in the list is at most 320K for voyage-2, and 120K for voyage-large-2, voyage-finance-2, voyage-multilingual-2, voyage-law-2, and voyage-code-2.
        public let input: [String]
        
        /// Type of the input text. Defaults to nil. Other options: query, document.
        public let inputType: String?
        
        /// Whether to truncate the input texts to fit within the context length. Defaults to true.
        /// If true, over-length input texts will be truncated to fit within the context length, before vectorized by the embedding model.
        /// If false, an error will be raised if any given text exceeds the context length.
        public let truncation: Bool
        
        /// Format in which the embeddings are encoded. We support two options:
        /// If not specified (defaults to null): the embeddings are represented as lists of floating-point numbers;
        /// base64: the embeddings are compressed to base64 encodings.
        public let encodingFormat: EncodingFormat?
        public enum EncodingFormat: String, Codable, Hashable, Sendable {
            case float
            case base64
        }
        
        init(
            model: VoyageAI.Model,
            input: [String],
            inputType: String? = nil,
            truncation: Bool = true,
            encodingFormat: EncodingFormat? = nil
        ) {
            self.model = model
            self.input = input
            self.inputType = inputType
            self.truncation = truncation
            self.encodingFormat = encodingFormat == .base64 ? .base64 : nil
        }
    }
}
