//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Swift
import SwiftAPI

extension _Gemini {
    public enum APIError: APIErrorProtocol {
        public typealias API = _Gemini.APISpecification
        
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
            public var serviceURL: String?
            public var clientID: String?
            
            public init(
                host: URL = URL(string: "https://generativelanguage.googleapis.com")!,
                apiKey: String? = nil,
                serviceURL: String? = nil,
                clientID: String? = nil
            ) {
                self.host = host
                self.apiKey = apiKey
                self.serviceURL = serviceURL
                self.clientID = clientID
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
        
        // Generate Content endpoint
        @POST
        @Path({ context -> String in
            "/v1beta/models/\(context.input.model):generateContent"
        })
        @Body(json: \.requestBody)
        var generateContent = Endpoint<RequestBodies.GenerateContentInput, ResponseBodies.GenerateContent, Void>()
        
        // Initial Upload Request endpoint
        @POST
        @Path("/upload/v1beta/files")
        @Header([
            "X-Goog-Upload-Command": "start, upload, finalize"
        ])
        @Body(multipart: .input)
        var uploadFile = Endpoint<RequestBodies.FileUploadInput, ResponseBodies.FileUpload, Void>()
        
        // File Status endpoint
        @GET
        @Path({ context -> String in
            "/v1beta/\(context.input.name.rawValue)"
        })
        var getFile = Endpoint<RequestBodies.FileStatusInput, _Gemini.File, Void>()
        
        @GET
        @Path("/v1beta/files")
        @Query({ context -> [String : String] in
            var parameters: [String : String] = [:]
            
            if let pageSize = context.input.pageSize {
                parameters["pageSize"] = String(pageSize)
            }
            
            if let pageToken = context.input.pageToken {
                parameters["pageToken"] = pageToken
            }
            
            return parameters
        })
        var listFiles = Endpoint<RequestBodies.FileListInput, _Gemini.FileList, Void>()
        
        // Delete File endpoint
        @DELETE
        @Path({ context -> String in
            "/\(context.input.fileURL.path)"
        })
        var deleteFile = Endpoint<RequestBodies.DeleteFileInput, Void, Void>()
        
        //Fine Tuning
        @POST
        @Path("/v1beta/tunedModels")
        @Body(json: \.requestBody)
        var createTunedModel = Endpoint<RequestBodies.CreateTunedModel, _Gemini.TuningOperation, Void>()
        
        @GET
        @Path({ context -> String in
            "/v1/\(context.input.operationName)"
        })
        var getTuningOperation = Endpoint<RequestBodies.GetOperation, _Gemini.TuningOperation, Void>()
        
        @GET
        @Path({ context -> String in
            "/v1beta/\(context.input.modelName)"
        })
        var getTunedModel = Endpoint<RequestBodies.GetTunedModel, _Gemini.TunedModel, Void>()
        
        @POST
        @Path({ context -> String in
            "/v1beta/\(context.input.model):generateContent"  // Use the model name directly
        })
        @Body(json: \.requestBody)
        var generateTunedContent = Endpoint<RequestBodies.GenerateContentInput, ResponseBodies.GenerateContent, Void>()
        
        @POST
        @Path({ context -> String in
            "/v1beta/models/\(context.input.model):embedContent"
        })
        @Body(json: \.input)
        var generateEmbedding = Endpoint<RequestBodies.EmbeddingInput, ResponseBodies.EmbeddingResponse, Void>()
    }
}

extension _Gemini.APISpecification {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<_Gemini.APISpecification, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            var request = try super.buildRequestBase(
                from: input,
                context: context
            )
            
            if let apiKey = context.root.configuration.apiKey {
                request = request.query([.init(name: "key", value: apiKey)])
            }
            
            return request
        }
        
        override public func decodeOutputBase(
            from response: Request.Response,
            context: DecodeOutputContext
        ) throws -> Output {
            
            print(response)
            
            try response.validate()
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
}
