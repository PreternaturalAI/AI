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
        
        // MARK: - Tools
        @GET
        @Path("/v0/evi/tools")
        var listTools = Endpoint<Void, ResponseBodies.ToolList, Void>()
        
        @POST
        @Path("/v0/evi/tools")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createTool = Endpoint<RequestBodies.CreateToolInput, HumeAI.Tool, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/tools/\(context.input.id)"
        })
        var listToolVersions = Endpoint<PathInput.ID, ResponseBodies.ToolList, Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/evi/tools/\(context.input.id ?? "")"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createToolVersion = Endpoint<RequestBodies.CreateToolInput, HumeAI.Tool.ToolVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/evi/tools/\(context.input.id)"
        })
        var deleteTool = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/evi/tools/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateToolName = Endpoint<RequestBodies.UpdateToolNameInput, Void, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/tools/\(context.input.id)/version/\(context.input.version)"
        })
        var getToolVersion = Endpoint<PathInput.IDWithVersion, HumeAI.Tool.ToolVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/evi/tools/\(context.input.id)/version/\(context.input.version)"
        })
        var deleteToolVersion = Endpoint<PathInput.IDWithVersion, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/evi/tools/\(context.input.id)/version/\(context.input.version)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateToolDescription = Endpoint<RequestBodies.UpdateToolDescriptionInput, HumeAI.Tool.ToolVersion, Void>()
        
        // MARK: - Prompts
        @GET
        @Path("/v0/evi/prompts")
        var listPrompts = Endpoint<Void, ResponseBodies.PromptList, Void>()
        
        @POST
        @Path("/v0/evi/prompts")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createPrompt = Endpoint<RequestBodies.CreatePromptInput, HumeAI.Prompt, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/prompts/\(context.input.id)"
        })
        var listPromptVersions = Endpoint<PathInput.ID, ResponseBodies.PromptList, Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/evi/prompts/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createPromptVersion = Endpoint<RequestBodies.CreatePromptVersionInput, HumeAI.Prompt.PromptVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/evi/prompts/\(context.input.id)"
        })
        var deletePrompt = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in 
            "/v0/evi/prompts/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updatePromptName = Endpoint<RequestBodies.UpdatePromptNameInput, Void, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/prompts/\(context.input.id)/version/\(context.input.version)"
        })
        var getPromptVersion = Endpoint<PathInput.IDWithVersion, HumeAI.Prompt.PromptVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/evi/prompts/\(context.input.id)/version/\(context.input.version)"
        })
        var deletePromptVersion = Endpoint<PathInput.IDWithVersion, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/evi/prompts/\(context.input.id)/version/\(context.input.version)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updatePromptDescription = Endpoint<RequestBodies.UpdatePromptDescriptionInput, Void, Void>()
        
        // MARK: - Custom Voices
        @GET
        @Path("/v0/evi/custom_voices")
        var listCustomVoices = Endpoint<Void, ResponseBodies.CustomVoiceList, Void>()
        
        @POST
        @Path("/v0/evi/custom_voices")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createCustomVoice = Endpoint<RequestBodies.CreateVoiceInput, HumeAI.Voice, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/custom_voices/\(context.input.id)"
        })
        var getCustomVoice = Endpoint<PathInput.ID, HumeAI.Voice, Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/evi/custom_voices/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createCustomVoiceVersion = Endpoint<RequestBodies.CreateVoiceVersionInput, HumeAI.Voice, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/evi/custom_voices/\(context.input.id)"
        })
        var deleteCustomVoice = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/evi/custom_voices/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateCustomVoiceName = Endpoint<RequestBodies.UpdateVoiceNameInput, Void, Void>()
        
        // MARK: - Configs
        @GET
        @Path("/v0/evi/configs")
        var listConfigs = Endpoint<Void, ResponseBodies.ConfigList, Void>()
        
        @POST
        @Path("/v0/evi/configs")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createConfig = Endpoint<RequestBodies.CreateConfigInput, HumeAI.Config, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/configs/\(context.input.id)/version/\(context.input.version)"
        })
        var listConfigVersions = Endpoint<PathInput.IDWithVersion, [ResponseBodies.ConfigVersion], Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/evi/configs/\(context.input.id)/version/\(context.input.version)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createConfigVersion = Endpoint<RequestBodies.CreateConfigVersionInput, ResponseBodies.ConfigVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/evi/configs/\(context.input.id)"
        })
        var deleteConfig = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/evi/configs/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateConfigName = Endpoint<RequestBodies.UpdateConfigNameInput, HumeAI.Config, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/configs/\(context.input.id)/version/\(context.input.version)"
        })
        var getConfigVersion = Endpoint<PathInput.IDWithVersion, ResponseBodies.ConfigVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/evi/configs/\(context.input.id)/version/\(context.input.version)"
        })
        var deleteConfigVersion = Endpoint<PathInput.IDWithVersion, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/evi/configs/\(context.input.id)/version/\(context.input.versionID)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateConfigDescription = Endpoint<RequestBodies.UpdateConfigDescriptionInput, ResponseBodies.ConfigVersion, Void>()
        
        // MARK: - Chats
        @GET
        @Path("/v0/evi/chats")
        var listChats = Endpoint<Void, ResponseBodies.ChatList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/chats/\(context.input.id)/events"
        })
        var listChatEvents = Endpoint<PathInput.ID, ResponseBodies.ChatEventList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/chats/\(context.input.id)/audio"
        })
        var getChatAudio = Endpoint<PathInput.ID, ResponseBodies.ChatAudio, Void>()
        
        // MARK: - Chat Groups
        @GET
        @Path("/v0/evi/chat_groups")
        var listChatGroups = Endpoint<Void, ResponseBodies.ChatGroupList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/chat_groups/\(context.input.id)"
        })
        var getChatGroup = Endpoint<PathInput.ID, HumeAI.ChatGroup, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/chat_groups/\(context.input.id)/events"
        })
        var listChatGroupEvents = Endpoint<PathInput.ID, ResponseBodies.ChatEventList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/evi/chat_groups/\(context.input.id)/audio"
        })
        var getChatGroupAudio = Endpoint<PathInput.ID, ResponseBodies.ChatAudio, Void>()
        
        // MARK: - Chat
        @POST
        @Path("/v0/evi/chat")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var chat = Endpoint<RequestBodies.ChatRequest, HumeAI.ChatResponse, Void>()
        
        // MARK: - Batch
        @GET
        @Path("/v0/batch/jobs")
        var listJobs = Endpoint<Void, [HumeAI.Job], Void>()
        
        @POST
        @Path("/v0/batch/jobs")
        @Body(json: \.input)
        var startInferenceJob = Endpoint<RequestBodies.BatchInferenceJobInput, HumeAI.JobID, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/batch/jobs/\(context.input.id)"
        })
        var getJobDetails = Endpoint<PathInput.ID, HumeAI.Job, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/batch/jobs/\(context.input.id)/predictions"
        })
        var getJobPredictions = Endpoint<PathInput.ID, [HumeAI.JobPrediction], Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/batch/jobs/\(context.input.id)/artifacts"
        })
        var getJobArtifacts = Endpoint<PathInput.ID, [String: String], Void>()
        
        // MARK: - Stream
        @POST
        @Path("/v0/stream/models")
        @Body(multipart: .input)
        var streamInference = Endpoint<RequestBodies.StreamInput, HumeAI.Job, Void>()
        
        // MARK: - Files
        @GET
        @Path("/v0/registry/files")
        var listFiles = Endpoint<Void, ResponseBodies.FileList, Void>()
        
        @POST
        @Path("/v0/registry/files")
        @Body(multipart: .input)
        var uploadFile = Endpoint<RequestBodies.UploadFileInput, HumeAI.File, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/registry/files/\(context.input.id)"
        })
        var getFile = Endpoint<PathInput.ID, HumeAI.File, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/registry/files/\(context.input.id)"
        })
        var deleteFile = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/registry/files/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateFileName = Endpoint<RequestBodies.UpdateFileNameInput, HumeAI.File, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/registry/files/\(context.input.id)/predictions"
        })
        var getFilePredictions = Endpoint<PathInput.ID, [HumeAI.JobPrediction], Void>()
        
        // MARK: - Datasets
        @GET
        @Path("/v0/registry/datasets")
        var listDatasets = Endpoint<Void, ResponseBodies.DatasetList, Void>()
        
        @POST
        @Path("/v0/registry/datasets")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createDataset = Endpoint<RequestBodies.CreateDatasetInput, HumeAI.Dataset, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/registry/datasets/\(context.input.id)"
        })
        var getDataset = Endpoint<PathInput.ID, HumeAI.Dataset, Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/registry/datasets/\(context.input.id)/version/\(context.input.version)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var createDatasetVersion = Endpoint<RequestBodies.CreateDatasetVersionInput, HumeAI.Dataset.DatasetVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/registry/datasets/\(context.input.id)"
        })
        var deleteDataset = Endpoint<PathInput.ID, Void, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/registry/datasets/\(context.input.id)/version/\(context.input.version)"
        })
        var listDatasetVersions = Endpoint<PathInput.IDWithVersion, [HumeAI.Dataset.DatasetVersion], Void>()
        // MARK: - Models
        @GET
        @Path("/v0/registry/models")
        var listModels = Endpoint<Void, ResponseBodies.ModelList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/registry/models/\(context.input.id)"
        })
        var getModel = Endpoint<PathInput.ID, HumeAI.Model, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/registry/models/\(context.input.id)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateModelName = Endpoint<RequestBodies.UpdateModelNameInput, Void, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/registry/models/version"
        })
        var listModelVersions = Endpoint<PathInput.ID, [HumeAI.Model.ModelVersion], Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/registry/models/\(context.input.id)/version/\(context.input.version)"
        })
        var getModelVersion = Endpoint<PathInput.IDWithVersion, HumeAI.Model.ModelVersion, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/registry/models/\(context.input.id)/version/\(context.input.versionId)"
        })
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var updateModelDescription = Endpoint<RequestBodies.UpdateModelDescriptionInput, Void, Void>()
        
        // MARK: - Jobs
        @POST
        @Path("/v0/registry/v0/batch/jobs/tl/train")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var startTrainingJob = Endpoint<RequestBodies.TrainingJobInput, HumeAI.JobID, Void>()
        
        @POST
        @Path("/v0/batch/jobs/tl/inference")
        @Body(json: \.input, keyEncodingStrategy: .convertToSnakeCase)
        var startCustomInferenceJob = Endpoint<RequestBodies.CustomInferenceJobInput, HumeAI.JobID, Void>()
    }
}

extension HumeAI.APISpecification {
    enum PathInput {
        struct ID: Codable {
            let id: String
        }
        
        struct IDWithVersion: Codable {
            let id: String
            let version: Int
        }
    }
    
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
                .header("X-Hume-Api-Key", apiKey)
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
