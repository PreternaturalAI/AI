//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import FoundationX
import Swallow

extension Cohere {
    public enum APIError: APIErrorProtocol {
        public typealias API = Cohere.APISpecification

        case apiKeyMissing
        case incorrectAPIKeyProvided
        case rateLimitExceeded
        case badRequest(API.Request.Error)
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
            URL(string: "https://api.cohere.com/v1/")!
        }
        
        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("embed")
        public var createEmbeddings = Endpoint<RequestBodies.CreateEmbedding, Cohere.Embeddings, Void>()
    }
}

extension Cohere.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<Cohere.APISpecification, Input, Output, Options> {
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

extension Cohere.APISpecification {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
    
    public enum ResponseBodies: _StaticSwift.Namespace {
        
    }
}

extension Cohere.APISpecification.RequestBodies {
    public struct CreateEmbedding: Codable, Hashable {
        private enum CodingKeys: String, CodingKey {
            case model
            case texts
            case inputType = "input_type"
            case embeddingTypes = "embedding_types"
            case truncate
        }
        
        public let model: String
        
        /// An array of strings for the model to embed. Maximum number of texts per call is 96. We recommend reducing the length of each text to be under 512 tokens for optimal quality.
        public let texts: [String]
        
        /// Specifies the type of input passed to the model. Required for embedding models v3 and higher.
        public let inputType: InputType
        public enum InputType: String, Codable, Hashable, Sendable {
            private enum CodingKeys: String, CodingKey {
                case searchDocument = "search_document"
                case searchQuery = "search_query"
                case classification
                case clustering
            }
            
            /// Used for embeddings stored in a vector database for search use-cases.
            case searchDocument
            /// Used for embeddings of search queries run against a vector DB to find relevant documents.
            case searchQuery
            ///  Used for embeddings passed through a text classifier.
            case classification
            /// Used for the embeddings run through a clustering algorithm.
            case clustering
        }
        
        /// Specifies the types of embeddings you want to get back. Not required and default is None, which returns the Embed Floats response type.
        public let embeddingTypes: [EmbeddingType]?
        public enum EmbeddingType: String, Codable, Hashable, Sendable {
            case float
            case int8
            case uint8
            case binary
            case ubinary
        }
        
        /// specify how the API will handle inputs longer than the maximum token length.
        /// Default: END
        public let truncate: TruncateStrategy
        public enum TruncateStrategy: String, Codable, Hashable, Sendable {
            /// when the input exceeds the maximum input token length an error will be returned.
            case NONE
            /// will discard the start of the input.
            case START
            /// will discard the end of the input.
            case END
        }
        
        init(model: Cohere.Model,
            texts: [String],
            inputType: InputType,
            embeddingTypes: [EmbeddingType]?,
            truncate: TruncateStrategy?
        ) {
            self.model = model.rawValue
            self.texts = texts
            self.inputType = inputType
            self.embeddingTypes = embeddingTypes
            self.truncate = truncate ?? .END
        }
    }
}
