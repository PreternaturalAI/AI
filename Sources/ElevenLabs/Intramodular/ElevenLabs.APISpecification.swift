//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import NetworkKit
import Swift
import SwiftAPI

extension ElevenLabs {
    public enum APIError: APIErrorProtocol {
        public typealias API = ElevenLabs.APISpecification
        
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
                host: URL = URL(string: "https://api.elevenlabs.io")!,
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
        
        // Voices endpoints
        @GET
        @Path("/v1/voices")
        var listVoices = Endpoint<Void, ResponseBodies.Voices, Void>()
        
        // Text to speech
        @POST
        @Path({ context -> String in
            "/v1/text-to-speech/\(context.input.voiceId)"
        })
        @Body(json: \.requestBody, keyEncodingStrategy: .convertToSnakeCase)
        var textToSpeech = Endpoint<RequestBodies.TextToSpeechInput, Data, Void>()
        
        // Speech to speech
        @POST
        @Path({ context -> String in
            "/v1/speech-to-speech/\(context.input.voiceId)/stream"
        })
        @Body(multipart: .input)
        var speechToSpeech = Endpoint<RequestBodies.SpeechToSpeechInput, Data, Void>()
        
        // Voice management
        @POST
        @Path("/v1/voices/add")
        @Body(multipart: .input)
        var addVoice = Endpoint<RequestBodies.AddVoiceInput, ResponseBodies.VoiceID, Void>()
        
        @POST
        @Path({ context -> String in
            "/v1/voices/\(context.input.voiceId)/edit"
        })
        @Body(multipart: .input)
        var editVoice = Endpoint<RequestBodies.EditVoiceInput, Bool, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v1/voices/\(context.input)"
        })
        var deleteVoice = Endpoint<String, Void, Void>()
    }
}

extension ElevenLabs.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<ElevenLabs.APISpecification, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            var request = try super.buildRequestBase(
                from: input,
                context: context
            )
            
            request = request.header("xi-api-key", context.root.configuration.apiKey)
                .header(.contentType(.json))
            
            return request
        }
        
        struct _ErrorWrapper: Codable, Hashable {
            let detail: ErrorDetail
            
            struct ErrorDetail: Codable, Hashable {
                let status: String
                let message: String
            }
        }
        
        override public func decodeOutputBase(
            from response: Request.Response,
            context: DecodeOutputContext
        ) throws -> Output {
            do {
                if Input.self == RequestBodies.EditVoiceInput.self {
                    print("TEsts")
                }
                try response.validate()
            } catch {
                let apiError: Error
                
                if let error = error as? HTTPRequest.Error {
                    let errorWrapper = try? response.decode(
                        _ErrorWrapper.self,
                        keyDecodingStrategy: .convertFromSnakeCase
                    )
                    
                    if let message = errorWrapper?.detail.message {
                        if message.contains("API key is missing") {
                            throw Error.apiKeyMissing
                        } else if message.contains("Invalid API key") {
                            throw Error.incorrectAPIKeyProvided
                        } else {
                            throw Error.unknown(message: message)
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
            
            if Output.self == Data.self {
                return response.data as! Output
            }
            
            if Input.self == RequestBodies.EditVoiceInput.self {
                print(response)
            }
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
}

extension ElevenLabs.APISpecification {
    public enum ResponseBodies {
        public struct Voices: Codable {
            public let voices: [ElevenLabs.Voice]
        }
        
        public struct VoiceID: Codable {
            public let voiceId: String
        }
    }
}
