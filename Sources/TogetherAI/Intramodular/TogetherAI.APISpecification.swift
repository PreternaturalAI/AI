//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import FoundationX
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
        
        @POST
        @Path("completions")
        public var createCompletion = Endpoint<RequestBodies.CreateCompletion, TogetherAI.Completion, Void>()
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
        public let model: TogetherAI.Model.Embedding
        public let input: [String]
    }
    
    public struct CreateCompletion: Codable, Hashable {
        
        private enum CodingKeys: String, CodingKey {
            case model
            case prompt
            case maxTokens = "max_tokens"
            case stream
            case stop
            case temperature
            case topP = "top_p"
            case topK = "top_k"
            case repetitionPenalty = "repetition_penalty"
            case logprobs
            case echo
            case choices = "n"
            case safetyModel = "safety_model"
        }
        
        public let model: TogetherAI.Model.Completion
        public let prompt: String
        
        // The maximum number of tokens to generate.
        // Defaults to 200
        public let maxTokens: Int?
        
        // If true, stream tokens as Server-Sent Events as the model generates them instead of waiting for the full model response. If false, return a single JSON object containing the results.
        public let stream: Bool?
        
        // A list of string sequences that will truncate (stop) inference text output. For example, "" will stop generation as soon as the model generates the given token.
        public let stop: [String]?
        
        // A decimal number that determines the degree of randomness in the response. A value of 1 will always yield the same output. A temperature less than 1 favors more correctness and is appropriate for question answering or summarization. A value greater than 1 introduces more randomness in the output.
        public let temperature: Double?
        
        // The top_p (nucleus) parameter is used to dynamically adjust the number of choices for each predicted token based on the cumulative probabilities. It specifies a probability threshold, below which all less likely tokens are filtered out. This technique helps to maintain diversity and generate more fluent and natural-sounding text.
        public let topP: Double?
        
        // The top_k parameter is used to limit the number of choices for the next predicted word or token. It specifies the maximum number of tokens to consider at each step, based on their probability of occurrence. This technique helps to speed up the generation process and can improve the quality of the generated text by focusing on the most likely options.
        public let topK: Double?
        
        // A number that controls the diversity of generated text by reducing the likelihood of repeated sequences. Higher values decrease repetition.
        public let repetitionPenalty: Double?
        
        // Number of top-k logprobs to return
        public let logprobs: Int?
        
        // Echo prompt in output. Can be used with logprobs to return prompt logprobs.
        public let echo: Bool?
        
        // How many completions to generate for each prompt
        public let choices: Int?
        
        // A moderation model to validate tokens. Choice between available moderation models found here: https://docs.together.ai/docs/inference-models#moderation-models
        public let safetyModel: String?
        
        public init(
            model: TogetherAI.Model.Completion,
            prompt: String,
            maxTokens: Int?,
            stream: Bool? = nil,
            stop: [String]? = nil,
            temperature: Double? = nil,
            topP: Double? = nil,
            topK: Double? = nil,
            repetitionPenalty: Double? = nil,
            logprobs: Int? = nil,
            echo: Bool? = nil,
            choices: Int? = nil,
            safetyModel: String? = nil
        ) {
            self.model = model
            self.prompt = prompt
            self.maxTokens = maxTokens ?? 200
            self.stream = stream
            self.stop = stop
            self.temperature = temperature
            self.topP = topP
            self.topK = topK
            self.repetitionPenalty = repetitionPenalty
            self.logprobs = logprobs
            self.echo = echo
            self.choices = choices
            self.safetyModel = safetyModel
        }
    }
}
