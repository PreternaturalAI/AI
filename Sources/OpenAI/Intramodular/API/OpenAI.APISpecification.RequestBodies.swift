//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import NetworkKit

extension OpenAI.APISpecification {
    public enum RequestBodies {
        
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateCompletion: Codable, Hashable {
        public let prompt: Either<String, [String]>
        public let model: OpenAI.Model
        public let suffix: String?
        public let maxTokens: Int?
        public let temperature: Double?
        public let topP: Double?
        public let n: Int?
        public let stream: Bool?
        public let logprobs: Int?
        public let stop: Either<String, [String]>?
        public let presencePenalty: Double?
        public let frequencyPenalty: Double?
        public let bestOf: Int?
        public let logitBias: [String: Int]?
        public let user: String?
        
        public init(
            prompt: Either<String, [String]>,
            model: OpenAI.Model,
            suffix: String?,
            maxTokens: Int?,
            temperature: Double? = 1,
            topP: Double? = 1,
            n: Int? = 1,
            stream: Bool?,
            logprobs: Int?,
            stop: Either<String, [String]>?,
            presencePenalty: Double?,
            frequencyPenalty: Double?,
            bestOf: Int?,
            logitBias: [String: Int]?,
            user: String?
        ) {
            if let bestOf = bestOf {
                if let n = n, n != 1, bestOf != 1 {
                    assert(bestOf > n)
                }
            }
            
            self.prompt = prompt
            self.model = model
            self.suffix = suffix
            self.maxTokens = maxTokens
            self.temperature = temperature
            self.topP = topP
            self.n = n
            self.stream = stream
            self.logprobs = logprobs
            self.stop = stop?.nilIfEmpty()
            self.presencePenalty = presencePenalty
            self.frequencyPenalty = frequencyPenalty
            self.bestOf = bestOf
            self.logitBias = logitBias
            self.user = user
        }
        
        public init(
            prompt: Either<String, [String]>,
            model: OpenAI.Model,
            parameters: OpenAI.APIClient.TextCompletionParameters,
            stream: Bool
        ) {
            self.init(
                prompt: prompt,
                model: model,
                suffix: parameters.suffix,
                maxTokens: parameters.maxTokens,
                temperature: parameters.temperature,
                topP: parameters.topProbabilityMass,
                n: parameters.n,
                stream: stream,
                logprobs: parameters.logprobs,
                stop: parameters.stop?.nilIfEmpty(),
                presencePenalty: parameters.presencePenalty,
                frequencyPenalty: parameters.frequencyPenalty,
                bestOf: parameters.bestOf,
                logitBias: parameters.logitBias,
                user: parameters.user
            )
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateEmbedding: Codable, Hashable {
        public let model: OpenAI.Model.Embedding
        public let input: [String]
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateChatCompletion: Codable, Hashable {
        private enum CodingKeys: String, CodingKey {
            case user
            case messages
            case functions = "functions"
            case functionCallingStrategy = "function_call"
            case model
            case temperature
            case topProbabilityMass = "top_p"
            case choices = "n"
            case stream
            case stop
            case maxTokens = "max_tokens"
            case presencePenalty = "presence_penalty"
            case frequencyPenalty = "frequency_penalty"
            case logprobs = "logprobs"
            case topLogprobs = "top_logprobs"
            case logitBias = "logit_bias"
            case responseFormat = "response_format"
            case seed = "seed"
        }
        
        public let messages: [OpenAI.ChatMessage]
        public let model: OpenAI.Model
        public let frequencyPenalty: Double?
        public let logitBias: [String: Int]?
        public let logprobs: Bool?
        public let topLogprobs: Int?
        public let maxTokens: Int?
        public let choices: Int?
        public let presencePenalty: Double?
        public let responseFormat: OpenAI.ChatCompletion.ResponseFormat?
        public let seed: String?
        public let stop: [String]?
        public let stream: Bool?
        public let temperature: Double?
        public let topProbabilityMass: Double?
        public let user: String?
        public let functions: [OpenAI.ChatFunctionDefinition]?
        public let functionCallingStrategy: OpenAI.FunctionCallingStrategy?

        public init(
            messages: [OpenAI.ChatMessage],
            model: OpenAI.Model,
            frequencyPenalty: Double? = nil,
            logitBias: [String : Int]? = nil,
            logprobs: Bool? = nil,
            topLogprobs: Int? = nil,
            maxTokens: Int? = nil,
            choices: Int? = nil,
            presencePenalty: Double? = nil,
            responseFormat: OpenAI.ChatCompletion.ResponseFormat? = nil,
            seed: String? = nil,
            stop: [String]? = nil,
            stream: Bool? = nil,
            temperature: Double? = nil,
            topProbabilityMass: Double? = nil,
            user: String? = nil,
            functions: [OpenAI.ChatFunctionDefinition]? = nil,
            functionCallingStrategy: OpenAI.FunctionCallingStrategy? = nil
        ) {
            self.messages = messages
            self.model = model
            self.frequencyPenalty = frequencyPenalty
            self.logitBias = logitBias
            self.logprobs = logprobs
            self.topLogprobs = topLogprobs
            self.maxTokens = maxTokens
            self.choices = choices
            self.presencePenalty = presencePenalty
            self.responseFormat = responseFormat
            self.seed = seed
            self.stop = stop
            self.stream = stream
            self.temperature = temperature
            self.topProbabilityMass = topProbabilityMass
            self.user = user
            self.functions = functions
            self.functionCallingStrategy = functionCallingStrategy
        }

        public init(
            user: String?,
            messages: [OpenAI.ChatMessage],
            functions: [OpenAI.ChatFunctionDefinition]?,
            functionCallingStrategy: OpenAI.FunctionCallingStrategy?,
            model: OpenAI.Model,
            temperature: Double?,
            topProbabilityMass: Double?,
            choices: Int?,
            stream: Bool?,
            stop: [String]?,
            maxTokens: Int?,
            presencePenalty: Double?,
            frequencyPenalty: Double?
        ) {
            self.user = user
            self.messages = messages
            self.functions = functions.nilIfEmpty()
            self.functionCallingStrategy = functions == nil ? nil : functionCallingStrategy
            self.model = model
            self.temperature = temperature
            self.topProbabilityMass = topProbabilityMass
            self.choices = choices
            self.stream = stream
            self.stop = stop
            self.maxTokens = maxTokens
            self.presencePenalty = presencePenalty
            self.frequencyPenalty = frequencyPenalty
            
            self.logitBias = nil
            self.logprobs = nil
            self.topLogprobs = nil
            self.responseFormat = nil
            self.seed = nil
        }
        
        public init(
            messages: [OpenAI.ChatMessage],
            model: OpenAI.Model,
            parameters: OpenAI.APIClient.ChatCompletionParameters,
            user: String? = nil,
            stream: Bool
        ) {
            self.init(
                user: user,
                messages: messages,
                functions: parameters.functions,
                functionCallingStrategy: parameters.functionCallingStrategy,
                model: model,
                temperature: parameters.temperature,
                topProbabilityMass: parameters.topProbabilityMass,
                choices: parameters.choices,
                stream: stream,
                stop: parameters.stop,
                maxTokens: parameters.maxTokens,
                presencePenalty: parameters.presencePenalty,
                frequencyPenalty: parameters.frequencyPenalty
            )
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct UploadFile: Codable, Hashable, Sendable {
        public var file: Data
        public var filename: String
        public var preferredMIMEType: String
        public var purpose: OpenAI.File.Purpose
        
        public init(
            file: Data,
            filename: String,
            preferredMIMEType: String,
            purpose: OpenAI.File.Purpose
        ) {
            self.file = file
            self.filename = filename
            self.preferredMIMEType = preferredMIMEType
            self.purpose = purpose
        }
    }
    
    public struct ListFiles {
        public let purpose: OpenAI.File.Purpose?
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateThread: Codable, Hashable, Sendable {
        public var messages: [OpenAI.ChatMessage]?
        public var metadata: [String: String]?
        
        public init(
            messages: [OpenAI.ChatMessage]? = nil,
            metadata: [String : String]? = nil
        ) {
            self.messages = messages
            self.metadata = metadata
        }
    }
    
    public struct CreateThreadAndRun: Codable, Hashable, Sendable {
        public var assistantID: String
        public var thread: CreateThread?
        public var model: OpenAI.Model?
        public var instructions: String?
        public var tools: [OpenAI.Tool]?
        public var metadata: [String: String] = [:]
        
        public init(
            assistantID: String,
            thread: CreateThread?,
            model: OpenAI.Model?,
            instructions: String?,
            tools: [OpenAI.Tool]?,
            metadata: [String : String]
        ) {
            self.assistantID = assistantID
            self.thread = thread
            self.model = model
            self.instructions = instructions
            self.tools = tools
            self.metadata = metadata
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateMessage: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case role
            case content
            case fileIdentifiers = "file_ids"
            case metadata
        }
        
        public let role: OpenAI.ChatRole
        public let content: String
        public let fileIdentifiers: [String]?
        public let metadata: [String: String]?
        
        public init(
            role: OpenAI.ChatRole,
            content: String,
            fileIdentifiers: [String]?,
            metadata: [String: String]?
        ) {
            self.role = role
            self.content = content
            self.fileIdentifiers = fileIdentifiers
            self.metadata = metadata
        }
        
        public init(from message: OpenAI.ChatMessage) throws {
            assert(message.role == .user) // only .user is supported by the API right now
            
            self.init(
                role: message.role,
                content: try message.body._textValue.unwrap(),
                fileIdentifiers: nil,
                metadata: nil
            )
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateRun: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case assistantID = "assistantId"
            case model
            case instructions
            case tools
            case metadata
        }
        
        public let assistantID: String
        public let model: OpenAI.Model?
        public let instructions: String?
        public let tools: [OpenAI.Tool]?
        public let metadata: [String: String]?
        
        public init(
            assistantID: String,
            model: OpenAI.Model?,
            instructions: String?,
            tools: [OpenAI.Tool]?,
            metadata: [String : String]?
        ) {
            self.assistantID = assistantID
            self.model = model
            self.instructions = instructions
            self.tools = tools
            self.metadata = metadata
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateSpeech: Codable {
        public let input: String
        public let model: OpenAI.Model.Speech
        public let voice: String
        public let responseFormat: String
        public let speed: String
        
        public enum CodingKeys: String, CodingKey {
            case input
            case model
            case voice
            case responseFormat = "response_format"
            case speed
        }

        public init(model: OpenAI.Model.Speech, 
                    input: String,
                    voice: String,
                    responseFormat: String,
                    speed: String) {
            self.model = model
            self.speed = speed
            self.input = input
            self.voice = voice
            self.responseFormat = responseFormat
        }
    }
}



// MARK: - Auxiliary

extension OpenAI.APISpecification.RequestBodies.CreateChatCompletion {
    public struct ChatFunctionDefinition: Codable, Hashable {
        public let name: String
        public let description: String
        public let parameters: JSONSchema
        
        public init(name: String, description: String, parameters: JSONSchema) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
}
