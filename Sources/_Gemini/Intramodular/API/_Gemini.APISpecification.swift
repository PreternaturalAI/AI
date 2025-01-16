//
//  _Gemini.APISpecification.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
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
        @Header({ context in
            [
                HTTPHeaderField(key: "X-Goog-Upload-Protocol", value: "resumable"),
                HTTPHeaderField(key: "X-Goog-Upload-Command", value: "start"),
                HTTPHeaderField(key: "X-Goog-Upload-Header-Content-Length", value: "\(context.input.fileData.count)"),
                HTTPHeaderField(key: "X-Goog-Upload-Header-Content-Type", value: context.input.mimeType),
                HTTPHeaderField.contentType(.json)
            ]
        })
        @Body(json: \RequestBodies.StartFileUploadInput.metadata)
        var startFileUpload = Endpoint<RequestBodies.StartFileUploadInput, String, Self.Options>()
        
        @POST
        @Path({ context in context.input.uploadUrl })
        @Header({ context in
            [
                HTTPHeaderField(key: "Content-Length", value: "\(context.input.fileSize)"),
                HTTPHeaderField(key: "X-Goog-Upload-Offset", value: "0"),
                HTTPHeaderField(key: "X-Goog-Upload-Command", value: "upload, finalize")
            ]
        })
        @Body(json: \RequestBodies.FinalizeFileUploadInput.data)
        var finalizeFileUpload = Endpoint<RequestBodies.FinalizeFileUploadInput, ResponseBodies.FileUpload, Void>()
        
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
            
            // FIXME: (@jared) - why are you replacing the query instead of appending a new query item? is this intentional?
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
            
            
            if let options: _Gemini.APISpecification.Options = context.options as? _Gemini.APISpecification.Options, let headerKey = options.outputHeaderKey {
                print("HEADERS: \(response.headerFields)")
                let stringValue: String? = response.headerFields.first (where: { $0.key == headerKey })?.value
                print(stringValue)
                
                switch Output.self {
                    case String.self:
                        return (try stringValue.unwrap()) as! Output
                    case Optional<String>.self:
                        return stringValue as! Output
                    default:
                        throw _Gemini.APIError.invalidContentType
                }
            }
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
    
    public class Options {
        var outputHeaderKey: HTTPHeaderField.Key?
        
        init(outputHeaderKey: HTTPHeaderField.Key? = nil) {
            self.outputHeaderKey = outputHeaderKey
        }
    }
}
