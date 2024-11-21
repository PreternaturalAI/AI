//
//  Rime.APISpecification.swift
//  AI
//
//  Created by Jared Davidson on 11/21/24.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Swift
import SwiftAPI

extension Rime {
    public enum APIError: APIErrorProtocol {
        public typealias API = Rime.APISpecification
        
        case apiKeyMissing
        case userIdMissing
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
                host: URL = URL(string: "https://users.rime.ai/")!,
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
        
        @GET
        @Path("/data/voices/voice_details.json")
        var listVoices = Endpoint<Void, ResponseBodies.Voices, Void>()
        
        @POST
        @Path("/v1/rime-tts")
        var textToSpeech = Endpoint<RequestBodies.TextToSpeechInput, ResponseBodies.TextToSpeechOutput, Void>()
    }
}

extension Rime.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<Rime.APISpecification, Input, Output, Options> {
        public override func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            var request: HTTPRequest = try super.buildRequestBase(
                from: input,
                context: context
            )
            
            request = request
                .header("Accept", "application/json")
                .header("Authorization", "Bearer \(context.root.configuration.apiKey ?? "")")
                .header(.contentType(.json))
            
            return request
        }
        
        public override func decodeOutputBase(
            from response: HTTPResponse,
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
