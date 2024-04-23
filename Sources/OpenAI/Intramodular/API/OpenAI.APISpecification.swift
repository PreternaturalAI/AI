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
        case badRequest(API.Request.Error)
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
        public var createEmbeddings = Endpoint<RequestBodies.CreateEmbedding, ResponseBodies.CreateEmbedding, Void>()
        
        // MARK: Completions
        
        @POST
        @Path("/v1/completions")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        public var createCompletions = Endpoint<RequestBodies.CreateCompletion, OpenAI.TextCompletion, Void>()
        
        @POST
        @Path("/v1/chat/completions")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        public var createChatCompletions = Endpoint<RequestBodies.CreateChatCompletion, OpenAI.ChatCompletion, Void>()
        
        // MARK: Threads
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @POST
        @Path("/v1/threads")
        @Body(json: .input, keyEncodingStrategy: .convertToSnakeCase)
        public var createThread = Endpoint<RequestBodies.CreateThread, OpenAI.Thread, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @GET
        @Path({ context -> String in
            "/v1/threads/\(context.input.rawValue)"
        })
        public var retrieveThread = Endpoint<OpenAI.Thread.ID, OpenAI.Thread, Void>()
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @DELETE
        @Path({ context -> String in
            "/v1/threads/\(context.input.rawValue)"
        })
        public var deleteThread = Endpoint<OpenAI.Thread.ID, JSON, Void>()
        
        // MARK: Messages
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @POST
        @Path({ context -> String in
            "/v1/threads/\(context.input.thread.rawValue)/messages"
        })
        @Body(json: \.requestBody, keyEncodingStrategy: .convertToSnakeCase)
        public var createMessageForThread = Endpoint<
            (thread: OpenAI.Thread.ID, requestBody: OpenAI.APISpecification.RequestBodies.CreateMessage),
            OpenAI.Message,
            Void
        >()
        
        // MARK: Files
        
        @POST
        @Path("/v1/files")
        @Body({ context -> HTTPRequest.Multipart.Content in
            var request: OpenAI.APISpecification.RequestBodies.UploadFile = context.input
            var content = HTTPRequest.Multipart.Content()
            
            content.append(
                .file(
                    request.file,
                    contentType: HTTPMediaType(
                        rawValue: request.preferredMIMEType
                    ),
                    fileName: request.filename,
                    forField: "file"
                )
            )
            
            content.append(.text(request.purpose.rawValue, forField: "purpose"))
            
            return content
        })
        public var uploadFile = Endpoint<OpenAI.APISpecification.RequestBodies.UploadFile, OpenAI.File, Void>()
        
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
        public var listFiles = Endpoint<OpenAI.APISpecification.RequestBodies.ListFiles, OpenAI.List<OpenAI.File>, Void>()

        @GET
        @Path({ context -> String in
            "/v1/files/\(context.input)"
        })
        public var retrieveFile = Endpoint<OpenAI.File.ID, OpenAI.File, Void>()
                
        @DELETE
        @Path({ context -> String in
            "/v1/files/\(context.input)"
        })
        public var deleteFile = Endpoint<OpenAI.File.ID, OpenAI.File.DeletionStatus, Void>()

        // MARK: Assistants
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @GET
        @Path({ context -> String in
            "/v1/threads/\(context.input)/messages"
        })
        public var listMessagesForThread = Endpoint<OpenAI.Thread.ID, OpenAI.List<OpenAI.Message>, Void>()

        @Header(["OpenAI-Beta": "assistants=v1"])
        @POST
        @Path({ context -> String in
            "/v1/threads/\(context.input.thread.rawValue)/runs"
        })
        @Body(json: \.requestBody, keyEncodingStrategy: .convertToSnakeCase)
        public var createRun = Endpoint<
            (thread: OpenAI.Thread.ID, requestBody: OpenAI.APISpecification.RequestBodies.CreateRun),
            OpenAI.Run,
            Void
        >()
        
        @Header(["OpenAI-Beta": "assistants=v1"])
        @GET
        @Path({ context -> String in
            "/v1/threads/\(context.input.thread.rawValue)/runs/\(context.input.run.id.rawValue)"
        })
        public var retrieveRunForThread = Endpoint<
            (thread: OpenAI.Thread.ID, run: OpenAI.Run.ID),
            OpenAI.Run,
            Void
        >()
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
                
                public var errorDescription: String? {
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
                
                if let error = error as? Request.Error {
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
                        } else {
                            runtimeIssue(_error)
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
