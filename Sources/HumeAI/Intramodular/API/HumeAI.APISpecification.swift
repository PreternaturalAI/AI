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
        @Path("/v0/tools")
        var listTools = Endpoint<Void, ResponseBodies.ToolList, Void>()
        
        @POST
        @Path("/v0/tools")
        @Body(json: \.input)
        var createTool = Endpoint<RequestBodies.CreateToolInput, HumeAI.Tool, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/tools/\(context.input.id)/versions"
        })
        var listToolVersions = Endpoint<PathInput.ID, [ResponseBodies.ToolVersion], Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/tools/\(context.input.id)/versions"
        })
        @Body(json: \.input)
        var createToolVersion = Endpoint<RequestBodies.CreateToolInput, ResponseBodies.ToolVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/tools/\(context.input.id)"
        })
        var deleteTool = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/tools/\(context.input.id)"
        })
        @Body(json: \.input)
        var updateToolName = Endpoint<RequestBodies.UpdateToolNameInput, HumeAI.Tool, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/tools/\(context.input.id)/versions/\(context.input.versionId)"
        })
        var getToolVersion = Endpoint<PathInput.IDWithVersion, ResponseBodies.ToolVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/tools/\(context.input.id)/versions/\(context.input.versionId)"
        })
        var deleteToolVersion = Endpoint<PathInput.IDWithVersion, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/tools/\(context.input.id)/versions/\(context.input.versionID)"
        })
        @Body(json: \.input)
        var updateToolDescription = Endpoint<RequestBodies.UpdateToolDescriptionInput, ResponseBodies.ToolVersion, Void>()
        
        // MARK: - Prompts
        @GET
        @Path("/v0/prompts")
        var listPrompts = Endpoint<Void, ResponseBodies.PromptList, Void>()
        
        @POST
        @Path("/v0/prompts")
        @Body(json: \.input)
        var createPrompt = Endpoint<RequestBodies.CreatePromptInput, HumeAI.Prompt, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/prompts/\(context.input.id)/versions"
        })
        var listPromptVersions = Endpoint<PathInput.ID, [HumeAI.Prompt.PromptVersion], Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/prompts/\(context.input.id)/versions"
        })
        @Body(json: \.input)
        var createPromptVersion = Endpoint<RequestBodies.CreatePromptVersionInput, HumeAI.Prompt.PromptVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/prompts/\(context.input.id)"
        })
        var deletePrompt = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in 
            "/v0/prompts/\(context.input.id)"
        })
        @Body(json: \.input)
        var updatePromptName = Endpoint<RequestBodies.UpdatePromptNameInput, HumeAI.Prompt, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/prompts/\(context.input.id)/versions/\(context.input.versionId)"
        })
        var getPromptVersion = Endpoint<PathInput.IDWithVersion, HumeAI.Prompt.PromptVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/prompts/\(context.input.id)/versions/\(context.input.versionId)"
        })
        var deletePromptVersion = Endpoint<PathInput.IDWithVersion, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/prompts/\(context.input.id)/versions/\(context.input.versionID)"
        })
        @Body(json: \.input)
        var updatePromptDescription = Endpoint<RequestBodies.UpdatePromptDescriptionInput, HumeAI.Prompt.PromptVersion, Void>()
        
        // MARK: - Custom Voices
        @GET
        @Path("/v0/custom-voices")
        var listCustomVoices = Endpoint<Void, ResponseBodies.CustomVoiceList, Void>()
        
        @POST
        @Path("/v0/custom-voices")
        @Body(json: \.input)
        var createCustomVoice = Endpoint<RequestBodies.CreateVoiceInput, ResponseBodies.Voice, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/custom-voices/\(context.input.id)"
        })
        var getCustomVoice = Endpoint<PathInput.ID, ResponseBodies.Voice, Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/custom-voices/\(context.input.id)/versions"
        })
        @Body(json: \.input)
        var createCustomVoiceVersion = Endpoint<RequestBodies.CreateVoiceVersionInput, ResponseBodies.Voice, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/custom-voices/\(context.input.id)"
        })
        var deleteCustomVoice = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/custom-voices/\(context.input.id)"
        })
        @Body(json: \.input)
        var updateCustomVoiceName = Endpoint<RequestBodies.UpdateVoiceNameInput, ResponseBodies.Voice, Void>()
        
        // MARK: - Configs
        @GET
        @Path("/v0/configs")
        var listConfigs = Endpoint<Void, ResponseBodies.ConfigList, Void>()
        
        @POST
        @Path("/v0/configs")
        @Body(json: \.input)
        var createConfig = Endpoint<RequestBodies.CreateConfigInput, HumeAI.Config, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/configs/\(context.input.id)/versions"
        })
        var listConfigVersions = Endpoint<PathInput.ID, [ResponseBodies.ConfigVersion], Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/configs/\(context.input.id)/versions"
        })
        @Body(json: \.input)
        var createConfigVersion = Endpoint<RequestBodies.CreateConfigVersionInput, ResponseBodies.ConfigVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/configs/\(context.input.id)"
        })
        var deleteConfig = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/configs/\(context.input.id)"
        })
        @Body(json: \.input)
        var updateConfigName = Endpoint<RequestBodies.UpdateConfigNameInput, HumeAI.Config, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/configs/\(context.input.id)/versions/\(context.input.versionId)"
        })
        var getConfigVersion = Endpoint<PathInput.IDWithVersion, ResponseBodies.ConfigVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/configs/\(context.input.id)/versions/\(context.input.versionId)"
        })
        var deleteConfigVersion = Endpoint<PathInput.IDWithVersion, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/configs/\(context.input.id)/versions/\(context.input.versionID)"
        })
        @Body(json: \.input)
        var updateConfigDescription = Endpoint<RequestBodies.UpdateConfigDescriptionInput, ResponseBodies.ConfigVersion, Void>()
        
        // MARK: - Chats
        @GET
        @Path("/v0/chats")
        var listChats = Endpoint<Void, ResponseBodies.ChatList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/chats/\(context.input.id)/events"
        })
        var listChatEvents = Endpoint<PathInput.ID, ResponseBodies.ChatEventList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/chats/\(context.input.id)/audio"
        })
        var getChatAudio = Endpoint<PathInput.ID, ResponseBodies.ChatAudio, Void>()
        
        // MARK: - Chat Groups
        @GET
        @Path("/v0/chat-groups")
        var listChatGroups = Endpoint<Void, ResponseBodies.ChatGroupList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/chat-groups/\(context.input.id)"
        })
        var getChatGroup = Endpoint<PathInput.ID, HumeAI.ChatGroup, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/chat-groups/\(context.input.id)/events"
        })
        var listChatGroupEvents = Endpoint<PathInput.ID, ResponseBodies.ChatEventList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/chat-groups/\(context.input.id)/audio"
        })
        var getChatGroupAudio = Endpoint<PathInput.ID, ResponseBodies.ChatAudio, Void>()
        
        // MARK: - Chat
        @POST
        @Path("/v0/chat")
        @Body(json: \.input)
        var chat = Endpoint<RequestBodies.ChatRequest, HumeAI.ChatResponse, Void>()
        
        // MARK: - Batch
        @GET
        @Path("/v0/batch/jobs")
        var listJobs = Endpoint<Void, ResponseBodies.JobList, Void>()
        
        @POST
        @Path("/v0/batch/jobs")
        @Body(json: \.input)
        var startInferenceJob = Endpoint<RequestBodies.BatchInferenceJobInput, HumeAI.Job, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/batch/jobs/\(context.input.id)"
        })
        var getJobDetails = Endpoint<PathInput.ID, HumeAI.Job, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/batch/jobs/\(context.input.id)/predictions"
        })
        var getJobPredictions = Endpoint<PathInput.ID, [HumeAI.Job.Prediction], Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/batch/jobs/\(context.input.id)/artifacts"
        })
        var getJobArtifacts = Endpoint<PathInput.ID, [String: String], Void>()
        
        // MARK: - Stream
        @POST
        @Path("/v0/stream")
        @Body(multipart: .input)
        var streamInference = Endpoint<RequestBodies.StreamInput, HumeAI.Job, Void>()
        
        // MARK: - Files
        @GET
        @Path("/v0/files")
        var listFiles = Endpoint<Void, ResponseBodies.FileList, Void>()
        
        @POST
        @Path("/v0/files")
        @Body(multipart: .input)
        var uploadFile = Endpoint<RequestBodies.UploadFileInput, HumeAI.File, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/files/\(context.input.id)"
        })
        var getFile = Endpoint<PathInput.ID, HumeAI.File, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/files/\(context.input.id)"
        })
        var deleteFile = Endpoint<PathInput.ID, Void, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/files/\(context.input.id)"
        })
        @Body(json: \.input)
        var updateFileName = Endpoint<RequestBodies.UpdateFileNameInput, HumeAI.File, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/files/\(context.input.id)/predictions"
        })
        var getFilePredictions = Endpoint<PathInput.ID, [HumeAI.Job.Prediction], Void>()
        
        // MARK: - Datasets
        @GET
        @Path("/v0/datasets")
        var listDatasets = Endpoint<Void, ResponseBodies.DatasetList, Void>()
        
        @POST
        @Path("/v0/datasets")
        @Body(json: \.input)
        var createDataset = Endpoint<RequestBodies.CreateDatasetInput, HumeAI.Dataset, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/datasets/\(context.input.id)"
        })
        var getDataset = Endpoint<PathInput.ID, HumeAI.Dataset, Void>()
        
        @POST
        @Path({ context -> String in
            "/v0/datasets/\(context.input.id)/versions"
        })
        @Body(json: \.input)
        var createDatasetVersion = Endpoint<RequestBodies.CreateDatasetVersionInput, HumeAI.Dataset.DatasetVersion, Void>()
        
        @DELETE
        @Path({ context -> String in
            "/v0/datasets/\(context.input.id)"
        })
        var deleteDataset = Endpoint<PathInput.ID, Void, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/datasets/\(context.input.id)/versions"
        })
        var listDatasetVersions = Endpoint<PathInput.ID, [HumeAI.Dataset.DatasetVersion], Void>()
        // MARK: - Models
        @GET
        @Path("/v0/models")
        var listModels = Endpoint<Void, ResponseBodies.ModelList, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/models/\(context.input.id)"
        })
        var getModel = Endpoint<PathInput.ID, HumeAI.Model, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/models/\(context.input.id)"
        })
        @Body(json: \.input)
        var updateModelName = Endpoint<RequestBodies.UpdateModelNameInput, HumeAI.Model, Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/models/\(context.input.id)/versions"
        })
        var listModelVersions = Endpoint<PathInput.ID, [ResponseBodies.ModelVersion], Void>()
        
        @GET
        @Path({ context -> String in
            "/v0/models/\(context.input.id)/versions/\(context.input.versionId)"
        })
        var getModelVersion = Endpoint<PathInput.IDWithVersion, ResponseBodies.ModelVersion, Void>()
        
        @PATCH
        @Path({ context -> String in
            "/v0/models/\(context.input.id)/versions/\(context.input.versionId)"
        })
        @Body(json: \.input)
        var updateModelDescription = Endpoint<RequestBodies.UpdateModelDescriptionInput, ResponseBodies.ModelVersion, Void>()
        
        // MARK: - Jobs
        @POST
        @Path("/v0/jobs/training")
        @Body(json: \.input)
        var startTrainingJob = Endpoint<RequestBodies.TrainingJobInput, HumeAI.Job, Void>()
        
        @POST
        @Path("/v0/jobs/inference")
        @Body(json: \.input)
        var startCustomInferenceJob = Endpoint<RequestBodies.CustomInferenceJobInput, HumeAI.Job, Void>()
    }
}

extension HumeAI.APISpecification {
    enum PathInput {
        struct ID: Codable {
            let id: String
        }
        
        struct IDWithVersion: Codable {
            let id: String
            let versionId: String
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
