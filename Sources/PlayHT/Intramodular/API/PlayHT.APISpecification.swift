//
//  PlayHT.APISpecification.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Swift
import SwiftAPI

extension PlayHT {
    public enum APIError: APIErrorProtocol {
        public typealias API = PlayHT.APISpecification
        
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
            public var userId: String?
            
            public init(
                host: URL = URL(string: "https://api.play.ht/api/v2")!,
                apiKey: String? = nil,
                userId: String? = nil
            ) {
                self.host = host
                self.apiKey = apiKey
                self.userId = userId
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
        
        // Voices endpoints
        @GET
        @Path("/voices")
        var listVoices = Endpoint<Void, ResponseBodies.Voices, Void>()

        // Stream text to speech
        @POST
        @Path("/tts/stream")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var streamTextToSpeech = Endpoint<RequestBodies.TextToSpeechInput, ResponseBodies.TextToSpeechResponse, Void>()
        
        @GET
        @Path("/cloned-voices")
        var listClonedVoices = Endpoint<Void, ResponseBodies.Voices, Void>()
        
        // Clone Voice
        @POST
        @Path("/cloned-voices/instant")
        @Body(multipart: .input)
        var instantCloneVoice = Endpoint<RequestBodies.InstantCloneVoiceInput, ResponseBodies.ClonedVoiceOutput, Void>()
        
        // Clone Voice
        @POST
        @Path("/cloned-voices/instant")
        @Body(multipart: .input)
        var instantCloneVoiceWithURL = Endpoint<RequestBodies.InstantCloneVoiceWithURLInput, ResponseBodies.ClonedVoiceOutput, Void>()
        
        // Delete cloned voice
        @DELETE
        @Path("/cloned-voices")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var deleteClonedVoice = Endpoint<RequestBodies.DeleteVoiceInput, Void, Void>()
    }
}

extension PlayHT.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<PlayHT.APISpecification, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            var request: HTTPRequest = try super.buildRequestBase(
                from: input,
                context: context
            )
            
            request = request
                .header("X-USER-ID", context.root.configuration.userId)
                .header("accept", "application/json")
                .header("AUTHORIZATION", context.root.configuration.apiKey)
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
