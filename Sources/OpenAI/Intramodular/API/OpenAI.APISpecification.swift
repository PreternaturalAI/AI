//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import NetworkKit
import Swift
import SwiftAPI

extension OpenAI {
    public enum APIError: APIErrorProtocol {
        public typealias API = OpenAI.APISpecification
        
        case apiKeyMissing
        case incorrectAPIKeyProvided
        case rateLimitExceeded
        case invalidContentType
        case maximumContentSizeLimitExceeded
        case badRequest(API.Request.Error)
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
                host: URL = URL(string: "https://api.openai.com")!,
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
        
        // MARK: Embeddings
        
        @POST
        @Path("/v1/embeddings")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createEmbeddings = Endpoint<RequestBodies.CreateEmbedding, ResponseBodies.CreateEmbedding, Void>()
        
        // MARK: Completions
        
        @POST
        @Path("/v1/completions")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createCompletions = Endpoint<RequestBodies.CreateCompletion, OpenAI.TextCompletion, Void>()
        
        @POST
        @Path("/v1/chat/completions")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createChatCompletions = Endpoint<RequestBodies.CreateChatCompletion, OpenAI.ChatCompletion, Void>()
        
        // MARK: Speech
        
        @POST
        @Path("/v1/audio/speech")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createSpeech = Endpoint<RequestBodies.CreateSpeech, Data, Void>()
        
        // MARK: Threads
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @POST
        @Path("/v1/threads")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createThread = Endpoint<RequestBodies.CreateThread, OpenAI.Thread, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @GET
        @Path({ context -> String in
            "/v1/threads/\(context.input.rawValue)"
        })
        var retrieveThread = Endpoint<OpenAI.Thread.ID, OpenAI.Thread, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @DELETE
        @Path({ context -> String in
            "/v1/threads/\(context.input.rawValue)"
        })
        var deleteThread = Endpoint<OpenAI.Thread.ID, JSON, Void>()
        
        // MARK: Messages
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @POST
        @Path({ context -> String in
            "/v1/threads/\(context.input.thread.rawValue)/messages"
        })
        @Body(json: \.requestBody, keyEncodingStrategy: .convertToSnakeCase)
        var createMessageForThread = Endpoint<
            (thread: OpenAI.Thread.ID, requestBody: OpenAI.APISpecification.RequestBodies.CreateMessage),
            OpenAI.Message,
            Void
        >()
        
        // MARK: Files
        
        @POST
        @Path("/v1/files")
        @Body(multipart: .input)
        var uploadFile = Endpoint<OpenAI.APISpecification.RequestBodies.UploadFile, OpenAI.File, Void>()
        
        @GET
        @Path({ context -> String in
            "/v1/files"
        })
        @Query({ context -> [String: String] in
            if let purpose = context.input.purpose {
                return ["purpose": purpose.rawValue]
            } else {
                return [:]
            }
        })
        var listFiles = Endpoint<OpenAI.APISpecification.RequestBodies.ListFiles, OpenAI.List<OpenAI.File>, Void>()
        
        @GET
        @Path({ context -> String in
            "/v1/files/\(context.input)"
        })
        var retrieveFile = Endpoint<OpenAI.File.ID, OpenAI.File, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v1/files/\(context.input)"
        })
        var deleteFile = Endpoint<OpenAI.File.ID, OpenAI.File.DeletionStatus, Void>()
        
        // MARK: Assistants
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @GET
        @Path({ context -> String in
            "/v1/threads/\(context.input)/messages"
        })
        var listMessagesForThread = Endpoint<OpenAI.Thread.ID, OpenAI.List<OpenAI.Message>, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @POST
        @Path({ context -> String in
            "/v1/threads/\(context.input.thread.rawValue)/runs"
        })
        @Body(json: \.requestBody, keyEncodingStrategy: .convertToSnakeCase)
        var createRun = Endpoint<
            (thread: OpenAI.Thread.ID, requestBody: OpenAI.APISpecification.RequestBodies.CreateRun),
            OpenAI.Run,
            Void
        >()
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @GET
        @Path({ context -> String in
            "/v1/threads/\(context.input.thread.rawValue)/runs/\(context.input.run.id.rawValue)"
        })
        var retrieveRunForThread = Endpoint<
            (thread: OpenAI.Thread.ID, run: OpenAI.Run.ID),
            OpenAI.Run,
            Void
        >()
        
        // MARK: Audio Transcription
        
        @POST
        @Path("/v1/audio/transcriptions")
        @Body(multipart: .input)
        var createAudioTranscription = Endpoint<RequestBodies.CreateTranscription, ResponseBodies.CreateTranscription, Void>()

        // MARK: Image Generation
        
        @POST
        @Path("/v1/images/generations")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createImage = Endpoint<RequestBodies.CreateImage, OpenAI.List<OpenAI.Image>, Void>()
        
        // Vector Store
        @Header(["OpenAI-Beta": "assistants=v2"])
        @POST
        @Path("/v1/vector_stores")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        var createVectorStore = Endpoint<RequestBodies.CreateVectorStore, OpenAI.VectorStore, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v2"])
        @GET
        @Path({ context -> String in
            "/v1/vector_stores"
        })
        var listVectorStores = Endpoint<OpenAI.APISpecification.RequestBodies.ListVectorStores, OpenAI.List<OpenAI.VectorStore>, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v2"])
        @GET
        @Path({ context -> String in
            "/v1/vector_stores/\(context.input.vector_store_id)"
        })
        var getVectorStore = Endpoint<OpenAI.APISpecification.RequestBodies.GetVectorStore, OpenAI.VectorStore, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v2"])
        @POST
        @Path({ context -> String in
            "/v1/vector_stores/\(context.input.vector_store_id)"
        })
        var updateVectorStore = Endpoint<OpenAI.APISpecification.RequestBodies.UpdateVectorStore, OpenAI.VectorStore, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v2"])
        @DELETE
        @Path({ context -> String in
            "/v1/vector_stores/\(context.input.vector_store_id)"
        })
        var deleteVectorStore = Endpoint<OpenAI.APISpecification.RequestBodies.DeleteVectorStore, OpenAI.VectorStore, Void>()
    }
}

extension OpenAI.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<OpenAI.APISpecification, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            let configuration = context.root.configuration
            
            var request = try super.buildRequestBase(
                from: input,
                context: context
            )
            
            if let apiKey = configuration.apiKey {
                request = request.header(.authorization(.bearer, apiKey))
            }
            
            request = request.header(.contentType(.json))
            
            return request
        }
        
        struct _ErrorWrapper: Codable, Hashable, Sendable {
            public struct Error: Codable, Hashable, LocalizedError, Sendable {
                public let type: String
                public let param: AnyCodable?
                public let message: String
                
                var errorDescription: String? {
                    message
                }
            }
            
            public let error: Error
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
                    let errorWrapper = try? response.decode(
                        _ErrorWrapper.self,
                        keyDecodingStrategy: .convertFromSnakeCase
                    )
                    
                    if let _error: _ErrorWrapper.Error = errorWrapper?.error {
                        if _error.message.contains("You didn't provide an API key") {
                            throw Error.apiKeyMissing
                        } else if _error.message.contains("Incorrect API key provided") {
                            throw Error.incorrectAPIKeyProvided
                        } else if _error.message.contains("Invalid content type.") {
                            throw Error.invalidContentType
                        } else if _error.message.contains("Maximum content size limit") {
                            throw Error.maximumContentSizeLimitExceeded
                        } else {
                            throw Error.unknown(message: _error.message)
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
            
            switch Output.self {
                case Data.self:
                    return try cast(response.data, to: Output.self)
                default:
                    do {
                        return try response.decode(
                            Output.self,
                            keyDecodingStrategy: .convertFromSnakeCase
                        )
                    } catch {
                        if Output.self == OpenAI.APISpecification.ResponseBodies.CreateTranscription.self {
                            if let string = response.data.toUTF8String() {
                                return try cast(OpenAI.APISpecification.ResponseBodies.CreateTranscription(
                                    language: nil,
                                    duration: nil,
                                    text: string,
                                    words: nil,
                                    segments: nil
                                ))
                            }
                        }
                        
                        throw error
                    }
            }
        }
    }
}
