//
//  HumeAI.APISpecification.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Swift
import SwiftAPI

extension HumeAI {
    public enum APIError: APIErrorProtocol {
        public typealias API = HumeAI.APISpecification
        
        case apiKeyMissing
        case audioDataError
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
                host: URL = URL(string: "https://api.hume.ai")!,
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
        
        // Custom Voice Endpoints
        @GET
        @Path("/v0/evi/custom_voices")
        var listVoices = Endpoint<Void, ResponseBodies.VoiceList, Void>()
        
        @POST
        @Path("/v0/evi/custom_voices")
        @Body(json: \.input)
        var createVoice = Endpoint<RequestBodies.CreateVoiceInput, ResponseBodies.Voice, Void>()
        
        @GET
        @Path("/v0/evi/custom_voices/{id}")
        var getVoice = Endpoint<Void, ResponseBodies.Voice, Void>()
        
        @POST
        @Path("/v0/evi/custom_voices/{id}")
        @Body(json: \.input)
        var createVoiceVersion = Endpoint<RequestBodies.CreateVoiceInput, ResponseBodies.Voice, Void>()
        
        @DELETE
        @Path("/v0/evi/custom_voices/{id}")
        var deleteVoice = Endpoint<Void, Void, Void>()
        
        @PATCH
        @Path("/v0/evi/custom_voices/{id}")
        @Body(json: \.input)
        var updateVoiceName = Endpoint<RequestBodies.UpdateVoiceNameInput, ResponseBodies.Voice, Void>()
    }
}

extension HumeAI.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<HumeAI.APISpecification, Input, Output, Options> {
        public override func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            var request: HTTPRequest = try super.buildRequestBase(
                from: input,
                context: context
            )
            
            guard let apiKey = context.root.configuration.apiKey, !apiKey.isEmpty else {
                throw HumeAI.APIError.apiKeyMissing
            }
            
            request = request
                .header("Accept", "application/json")
                .header(.authorization(.bearer, apiKey))
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
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
}
