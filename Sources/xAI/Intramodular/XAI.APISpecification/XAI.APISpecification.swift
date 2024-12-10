//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import FoundationX
import OpenAI
import NetworkKit
import Swallow

extension XAI {
    public enum APIError: APIErrorProtocol {
        public typealias API = XAI.APISpecification
        
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
            URL(string: "https://api.x.ai/")!
        }
        
        public var id: some Hashable {
            configuration
        }
        
        @POST
        @Path("/v1/chat/completions")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createChatCompletions = Endpoint<RequestBodies.CreateChatCompletion, OpenAI.ChatCompletion, Void>()

        
        
    }
}

extension XAI.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<XAI.APISpecification, Input, Output, Options> {
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
            let detail: [ErrorDetail]
            
            struct ErrorDetail: Codable, Hashable, Sendable {
                let loc: [ErrorLocation]
                let msg: String
                let type: String
                
                enum ErrorLocation: Codable, Hashable, Sendable {
                    case string(String)
                    case integer(Int)
                    
                    init(from decoder: Decoder) throws {
                        let container = try decoder.singleValueContainer()
                        if let stringValue = try? container.decode(String.self) {
                            self = .string(stringValue)
                        } else if let intValue = try? container.decode(Int.self) {
                            self = .integer(intValue)
                        } else {
                            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode ErrorLocation")
                        }
                    }
                    
                    func encode(to encoder: Encoder) throws {
                        var container = encoder.singleValueContainer()
                        switch self {
                        case .string(let value):
                            try container.encode(value)
                        case .integer(let value):
                            try container.encode(value)
                        }
                    }
                }
            }
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
                    if let errorWrapper = try? response.decode(
                        _ErrorWrapper.self,
                        keyDecodingStrategy: .convertFromSnakeCase
                    ) {
                        let errorMsg = errorWrapper.detail.first?.msg ?? ""
                        if errorMsg.contains("You didn't provide an API key") {
                            throw Error.apiKeyMissing
                        } else if errorMsg.contains("Incorrect API key provided") {
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

extension XAI.APISpecification {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
    
    public enum ResponseBodies: _StaticSwift.Namespace {
        
    }
}
