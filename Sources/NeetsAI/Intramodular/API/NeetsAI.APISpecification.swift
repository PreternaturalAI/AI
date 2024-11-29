//
//  NeetsAI.APISpecification.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Swift
import SwiftAPI

extension NeetsAI {
    public enum APIError: APIErrorProtocol {
        public typealias API = NeetsAI.APISpecification
        
        case apiKeyMissing
        case incorrectAPIKeyProvided
        case rateLimitExceeded
        case invalidContentType
        case badRequest(request: API.Request?, error: API.Request.Error)
        case unknown(message: String)
        case runtime(AnyError)
        
        public var traits: ErrorTraits {
            [.domain(.networking)]
        }
    }
    
    public struct APISpecification: RESTAPISpecification {
        public typealias Error = APIError
        
        public struct Configuration: Codable, Hashable {
            public var host: URL
            public var apiKey: String?
            
            public init(
                host: URL = URL(string: "https://api.neets.ai")!,
                apiKey: String? = nil
            ) {
                self.host = host
                self.apiKey = apiKey
            }
        }
        
        public let configuration: Configuration
        
        public var host: URL {
            configuration.host
        }
        
        public var id: some Hashable {
            configuration
        }
        
        public init(configuration: Configuration) {
            self.configuration = configuration
        }
        
        // Voice Management Endpoint
        @GET
        @Path("/v1/voices")
        var listVoices = Endpoint<Void, [Voice], Void>()
        
        // Text to Speech Endpoint
        @POST
        @Path("/v1/tts")
        @Body(json: \.input)
        var generateSpeech = Endpoint<RequestBodies.TTSInput, Data, Void>()
        
        // Chat Completion Endpoint
        @POST
        @Path("/v1/chat/completions")
        @Body(json: \.input)
        var chatCompletion = Endpoint<RequestBodies.ChatInput, ResponseBodies.ChatCompletion, Void>()
    }
}

extension NeetsAI.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<NeetsAI.APISpecification, Input, Output, Options> {
        public override func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            var request: HTTPRequest = try super.buildRequestBase(
                from: input,
                context: context
            )
            
            guard let apiKey = context.root.configuration.apiKey, !apiKey.isEmpty else {
                throw NeetsAI.APIError.apiKeyMissing
            }
            
            request = request
                .header("Accept", "application/json")
                .header("X-API-Key", apiKey)
                .header(.contentType(.json))
            
            return request
        }
        
        override public func decodeOutputBase(
            from response: Request.Response,
            context: DecodeOutputContext
        ) throws -> Output {
            do {
                try response.validate()
            } catch {
                let apiError: Error
                
                if let error = error as? HTTPRequest.Error {
                    if response.statusCode.rawValue == 401 {
                        apiError = .incorrectAPIKeyProvided
                    } else if response.statusCode.rawValue == 429 {
                        apiError = .rateLimitExceeded
                    } else {
                        apiError = .badRequest(error)
                    }
                } else {
                    apiError = .runtime(error)
                }
                
                throw apiError
            }
            
            if Output.self == Data.self {
                return response.data as! Output
            }
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
}
