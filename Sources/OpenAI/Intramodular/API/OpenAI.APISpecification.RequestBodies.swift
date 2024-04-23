//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import NetworkKit
import LargeLanguageModels

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
        
        /// Encapsulates the voices available for audio generation.
        ///
        /// To get aquinted with each of the voices and listen to the samples visit:
        /// [OpenAI Text-to-Speech – Voice Options](https://platform.openai.com/docs/guides/text-to-speech/voice-options)
        public enum Voice: String, Codable, CaseIterable {
            case alloy
            case echo
            case fable
            case onyx
            case nova
            case shimmer
        }
        
        public enum ResponseFormat: String, Codable, CaseIterable {
            case mp3
            case opus
            case aac
            case flac
        }

        /// The text to generate audio for. The maximum length is 4096 characters.
        public let input: String
        /// One of the available TTS models: tts-1 or tts-1-hd
        public let model: OpenAI.Model
        /// The voice to use when generating the audio. Supported voices are alloy, echo, fable, onyx, nova, and shimmer. Previews of the voices are available in the Text to speech guide.
        /// https://platform.openai.com/docs/guides/text-to-speech/voice-options
        public let voice: Voice
        /// The format to audio in. Supported formats are mp3, opus, aac, and flac.
        /// Defaults to mp3
        public let responseFormat: ResponseFormat?
        /// The speed of the generated audio. Select a value from **0.25** to **4.0**. **1.0** is the default.
        /// Defaults to 1
        public let speed: String?
        
        public enum CodingKeys: String, CodingKey {
            case model
            case input
            case voice
            case responseFormat = "response_format"
            case speed
        }

        public init(model: OpenAI.Model, input: String, voice: Voice, responseFormat: ResponseFormat = .mp3, speed: Double?) {
            self.model = model
            self.speed = CreateSpeech.normalizedSpeechSpeed(for: speed)
            self.input = input
            self.voice = voice
            self.responseFormat = responseFormat
        }
        
        enum Speed: Double {
            case normal = 1.0
            case max = 4.0
            case min = 0.25
        }
        
        static func normalizedSpeechSpeed(for inputSpeed: Double?) -> String {
            guard let inputSpeed else { return "\(Self.Speed.normal.rawValue)" }
            let isSpeedOutOfBounds = inputSpeed <= Self.Speed.min.rawValue || Self.Speed.max.rawValue <= inputSpeed
            guard !isSpeedOutOfBounds else {
                return inputSpeed < Self.Speed.min.rawValue ? "\(Self.Speed.min.rawValue)" : "\(Self.Speed.max.rawValue)"
            }
            return "\(inputSpeed)"
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    public struct CreateTranscription: Codable {
        
        public enum ResponseFormat: String, Codable, CaseIterable {
            case json
            case text
            case srt
            case verboseJSON = "verbose_json"
            case vtt
        }

        /// The audio file object (not file name) to transcribe, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
        public let file: OpenAI.File
        ///An optional text to guide the model's style or continue a previous audio segment. The prompt should match the audio language.
        public let prompt: String?
        /// ID of the model to use. Only whisper-1 (which is powered by our open source Whisper V2 model) is currently available.
        public let model: OpenAI.Model
        
        /// The language of the input audio. Supplying the input language in ISO-639-1 format will improve accuracy and latency.
        /// https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes
        public let language: LargeLanguageModels.ISO639LanguageCode?
        
        /// Defaults to 0
        public let temperature: Double?
         
        ///The timestamp granularities to populate for this transcription. response_format must be set verbose_json to use timestamp granularities. Either or both of these options are supported: word, or segment. Note: There is no additional latency for segment timestamps, but generating word timestamps incurs additional latency.
        public enum TimestampGranularities: String, Codable, CaseIterable {
            case word
            case segment
        }
        public let timestampGranularities: TimestampGranularities?

        /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
        /// Defaults to verbose_json
        public let responseFormat: ResponseFormat?
        
        
        public enum CodingKeys: String, CodingKey {
            case file
            case prompt
            case model
            case language
            case temperature
            case timestampGranularities = "timestamp_granularities[]"
            case responseFormat = "response_format"
        }

        public init(file: OpenAI.File,
                    prompt: String?,
                    model: OpenAI.Model = OpenAI.Model.transcriptions(.whisper_1),
                    language: LargeLanguageModels.ISO639LanguageCode? = nil,
                    temperature: Double? = 0,
                    timestampGranularities: TimestampGranularities? = nil,
                    responseFormat: ResponseFormat? = ResponseFormat.verboseJSON
            ) {
            self.file = file
            self.prompt = prompt
            self.model = model
            self.language = language
            self.temperature = temperature
            self.timestampGranularities = timestampGranularities
            if let _ = timestampGranularities {
                // timestampGranularities require for response format to be verboseJSON
                self.responseFormat = .verboseJSON
            } else {
                self.responseFormat = responseFormat
            }
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
