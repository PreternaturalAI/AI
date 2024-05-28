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
    struct CreateCompletion: Codable, Hashable {
        let prompt: Either<String, [String]>
        let model: OpenAI.Model
        let suffix: String?
        let maxTokens: Int?
        let temperature: Double?
        let topP: Double?
        let n: Int?
        let stream: Bool?
        let logprobs: Int?
        let stop: Either<String, [String]>?
        let presencePenalty: Double?
        let frequencyPenalty: Double?
        let bestOf: Int?
        let logitBias: [String: Int]?
        let user: String?
        
        init(
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
        
        init(
            prompt: Either<String, [String]>,
            model: OpenAI.Model,
            parameters: OpenAI.Client.TextCompletionParameters,
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
    struct CreateEmbedding: Codable, Hashable {
        let model: OpenAI.Model.Embedding
        let input: [String]
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct CreateChatCompletion: Codable, Hashable {
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
        
        let messages: [OpenAI.ChatMessage]
        let model: OpenAI.Model
        let frequencyPenalty: Double?
        let logitBias: [String: Int]?
        let logprobs: Bool?
        let topLogprobs: Int?
        let maxTokens: Int?
        let choices: Int?
        let presencePenalty: Double?
        let responseFormat: OpenAI.ChatCompletion.ResponseFormat?
        let seed: String?
        let stop: [String]?
        let stream: Bool?
        let temperature: Double?
        let topProbabilityMass: Double?
        let user: String?
        let functions: [OpenAI.ChatFunctionDefinition]?
        let functionCallingStrategy: OpenAI.FunctionCallingStrategy?
        
        init(
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
        
        init(
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
        
        init(
            messages: [OpenAI.ChatMessage],
            model: OpenAI.Model,
            parameters: OpenAI.Client.ChatCompletionParameters,
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
    struct UploadFile: Codable, Hashable, HTTPRequest.Multipart.ContentConvertible, Sendable {
        var file: Data
        var filename: String
        var preferredMIMEType: String
        var purpose: OpenAI.File.Purpose
        
        init(
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
        
        func __conversion() throws -> HTTPRequest.Multipart.Content {
            var result = HTTPRequest.Multipart.Content()
            
            result.append(
                .file(
                    named: "file",
                    data: file,
                    filename: filename,
                    contentType: HTTPMediaType(
                        rawValue: preferredMIMEType
                    )
                )
            )
            
            result.append(
                .text(
                    named: "purpose",
                    value: purpose.rawValue
                )
            )
            
            return result
        }
    }
    
    struct ListFiles {
        let purpose: OpenAI.File.Purpose?
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct CreateThread: Codable, Hashable, Sendable {
        var messages: [OpenAI.ChatMessage]?
        var metadata: [String: String]?
        
        init(
            messages: [OpenAI.ChatMessage]? = nil,
            metadata: [String : String]? = nil
        ) {
            self.messages = messages
            self.metadata = metadata
        }
    }
    
    struct CreateThreadAndRun: Codable, Hashable, Sendable {
        var assistantID: String
        var thread: CreateThread?
        var model: OpenAI.Model?
        var instructions: String?
        var tools: [OpenAI.Tool]?
        var metadata: [String: String] = [:]
        
        init(
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
    struct CreateMessage: Codable, Hashable, Sendable {
        enum CodingKeys: String, CodingKey {
            case role
            case content
            case fileIdentifiers = "file_ids"
            case metadata
        }
        
        let role: OpenAI.ChatRole
        let content: String
        let fileIdentifiers: [String]?
        let metadata: [String: String]?
        
        init(
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
        
        init(from message: OpenAI.ChatMessage) throws {
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
    struct CreateRun: Codable, Hashable, Sendable {
        enum CodingKeys: String, CodingKey {
            case assistantID = "assistantId"
            case model
            case instructions
            case tools
            case metadata
        }
        
        let assistantID: String
        let model: OpenAI.Model?
        let instructions: String?
        let tools: [OpenAI.Tool]?
        let metadata: [String: String]?
        
        init(
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
    struct CreateSpeech: Codable {
        enum ResponseFormat: String, Codable, CaseIterable {
            case mp3
            case opus
            case aac
            case flac
        }
        
        /// The text to generate audio for. The maximum length is 4096 characters.
        let input: String
        /// One of the available TTS models: tts-1 or tts-1-hd
        let model: OpenAI.Model
        /// The voice to use when generating the audio. Supported voices are alloy, echo, fable, onyx, nova, and shimmer. Previews of the voices are available in the Text to speech guide.
        /// https://platform.openai.com/docs/guides/text-to-speech/voice-options
        let voice: OpenAI.Speech.Voice
        /// The format to audio in. Supported formats are mp3, opus, aac, and flac.
        /// Defaults to mp3
        let responseFormat: ResponseFormat?
        /// The speed of the generated audio. Select a value from **0.25** to **4.0**. **1.0** is the default.
        /// Defaults to 1
        let speed: String?
        
        enum CodingKeys: String, CodingKey {
            case model
            case input
            case voice
            case responseFormat = "response_format"
            case speed
        }
        
        init(
            model: OpenAI.Model,
            input: String,
            voice: OpenAI.Speech.Voice,
            responseFormat: ResponseFormat = .mp3,
            speed: Double?
        ) {
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
        
        fileprivate static func normalizedSpeechSpeed(
            for inputSpeed: Double?
        ) -> String {
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
    struct CreateTranscription: Codable, HTTPRequest.Multipart.ContentConvertible {
        enum CodingKeys: String, CodingKey {
            case file
            case filename
            case preferredMIMEType
            case prompt
            case model
            case language
            case temperature
            case timestampGranularities = "timestamp_granularities[]"
            case responseFormat = "response_format"
        }
        
        /// The audio file object to transcribe, in one of these formats: flac, mp3, mp4, mpeg, mpga, m4a, ogg, wav, or webm.
        let file: Data
        let filename: String
        let preferredMIMEType: HTTPMediaType
        
        /// An optional text to guide the model's style or continue a previous audio segment. The prompt should match the audio language.
        let prompt: String?
        /// ID of the model to use. Only whisper-1 (which is powered by our open source Whisper V2 model) is currently available.
        let model: OpenAI.Model
        
        /// The language of the input audio. Supplying the input language in ISO-639-1 format will improve accuracy and latency.
        /// https://en.wikipedia.org/wiki/List_of_ISO_639_language_codes
        let language: LargeLanguageModels.ISO639LanguageCode?
        
        /// Defaults to 0
        let temperature: Double?
        
        let timestampGranularities: [OpenAI.AudioTranscription.TimestampGranularity]?
        
        /// The format of the transcript output, in one of these options: json, text, srt, verbose_json, or vtt.
        /// Defaults to verbose_json
        let responseFormat: OpenAI.AudioTranscription.ResponseFormat?
        
        init(
            file: Data,
            filename: String,
            preferredMIMEType: HTTPMediaType,
            prompt: String?,
            model: OpenAI.Model = OpenAI.Model.whisper(.whisper_1),
            language: LargeLanguageModels.ISO639LanguageCode? = nil,
            temperature: Double? = 0,
            timestampGranularities: [OpenAI.AudioTranscription.TimestampGranularity]? = nil,
            responseFormat: OpenAI.AudioTranscription.ResponseFormat? = .verboseJSON
        ) {
            self.file = file
            self.filename = filename
            self.preferredMIMEType = preferredMIMEType
            self.prompt = prompt
            self.model = model
            self.language = language
            self.temperature = temperature
            self.timestampGranularities = timestampGranularities
            self.responseFormat = responseFormat
        }
        
        func __conversion() -> HTTPRequest.Multipart.Content {
            var result = HTTPRequest.Multipart.Content()
            
            result.append(
                .file(
                    named: "file",
                    data: file,
                    filename: filename,
                    contentType: preferredMIMEType
                )
            )
            
            result.append(
                .text(
                    named: "model",
                    value: model.rawValue
                )
            )
            
            if let prompt = prompt {
                result.append(
                    .text(
                        named: "prompt",
                        value: prompt
                    )
                )
            }
            
            if let responseFormat = responseFormat {
                result.append(
                    .text(
                        named: "response_format",
                        value: responseFormat.rawValue
                    )
                )
            }
            
            if let temperature = temperature {
                result.append(
                    .text(
                        named: "temperature",
                        value: temperature.formatted(toDecimalPlaces: 3)
                    )
                )
            }
            
            if let language = language {
                result.append(
                    .text(
                        named: "language",
                        value: language.rawValue
                    )
                )
            }
            
            if let timestampGranularities = timestampGranularities {
                let granularities: String = timestampGranularities
                    .map({ "\"\($0.rawValue)\"" })
                    .joined(separator: ", ")
                    .addingPrefixIfMissing("[")
                    .addingSuffixIfMissing("]")
                
                result.append(
                    .string(
                        named: "timestamp_granularities[]",
                        value: granularities
                    )
                )
            }
            
            return result
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct CreateImage: Codable {
        enum CodingKeys: String, CodingKey {
            case prompt
            case model
            case numberOfImages = "n"
            case responseFormat = "response_format"
            case quality
            case size
            case style
            case user
        }
        
        let prompt: String
        let model: OpenAI.Model.DALL_E
        let numberOfImages: Int
        let responseFormat: OpenAI.Client.ImageResponseFormat
        let quality: String
        let size: String
        let style: String
        let user: String?
        
        init(
            prompt: String,
            model: OpenAI.Model.DALL_E,
            responseFormat: OpenAI.Client.ImageResponseFormat,
            numberOfImages: Int,
            quality: OpenAI.Image.Quality = .standard,
            size: OpenAI.Image.Size = .w1024h1024,
            style: OpenAI.Image.Style = .vivid,
            user: String? = nil
        ) {
            self.prompt = prompt
            self.model = model
            self.numberOfImages = numberOfImages
            self.responseFormat = responseFormat
            self.quality = quality.rawValue
            self.size = size.rawValue
            self.style = style.rawValue
            self.user = user
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct CreateVectorStore: Codable {
        enum CodingKeys: String, CodingKey {
            case name
            case fileIDs = "file_ids"
            case expiresAfter = "expires_after"
            case metadata
        }
        
        /// The name of the vector store.
        let name: String?
        
        /// A list of File IDs that the vector store should use. Useful for tools like file_search that can access files.
        let fileIDs: [String]?
        
        /// The expiration policy for a vector store.
        /// anchor (string) - Anchor timestamp after which the expiration policy applies. Supported anchors: last_active_at.
        /// days (integer) - The number of days after the anchor time that the vector store will expire.
        let expiresAfter: OpenAI.VectorStore.ExpiresAfter?
        
        /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
        let metadata: [String: String]?
        
        init(
            name: String?,
            fileIDs: [String]?,
            expiresAfter: OpenAI.VectorStore.ExpiresAfter?,
            metadata: [String: String]?
        ) {
            self.fileIDs = fileIDs
            self.name = name
            self.expiresAfter = expiresAfter
            self.metadata = metadata
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct ListVectorStores: Codable {
        enum CodingKeys: String, CodingKey {
            case limit
            case order
            case after
            case before
        }
        
        /// A limit on the number of objects to be returned. Limit can range between 1 and 100, and the default is 20.
        let limit: Int?
        
        /// Sort order by the created_at timestamp of the objects. asc for ascending order and desc for descending order.
        let order: String?
        
        /// A cursor for use in pagination. after is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include after=obj_foo in order to fetch the next page of the list.
        let after: String?
        
        /// A cursor for use in pagination. before is an object ID that defines your place in the list. For instance, if you make a list request and receive 100 objects, ending with obj_foo, your subsequent call can include before=obj_foo in order to fetch the previous page of the list.
        let before: String?
        
        init(
            limit: Int?,
            order: OpenAI.VectorStore.Order?,
            after: String?,
            before: String?
        ) {
            self.limit = limit
            self.order = order?.rawValue
            self.after = after
            self.before = before
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct GetVectorStore: Codable {
        enum CodingKeys: String, CodingKey {
            case vector_store_id
        }
        
        /// The ID of the vector store to retrieve.
        let vector_store_id: String
        
        init(
            vector_store_id: String
        ) {
            self.vector_store_id = vector_store_id
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct UpdateVectorStore: Codable {
        enum CodingKeys: String, CodingKey {
            case vector_store_id
            case name
            case expiresAfter = "expires_after"
            case metadata
        }
        
        /// The ID of the vector store to modify.
        let vector_store_id: String
        
        /// The name of the vector store.
        let name: String?
        
        /// The expiration policy for a vector store.
        /// anchor (string) - Anchor timestamp after which the expiration policy applies. Supported anchors: last_active_at.
        /// days (integer) - The number of days after the anchor time that the vector store will expire.
        let expiresAfter: OpenAI.VectorStore.ExpiresAfter?
        
        /// Set of 16 key-value pairs that can be attached to an object. This can be useful for storing additional information about the object in a structured format. Keys can be a maximum of 64 characters long and values can be a maxium of 512 characters long.
        let metadata: [String: String]?
        
        init(
            vectorStoreID: String,
            name: String?,
            expiresAfter: OpenAI.VectorStore.ExpiresAfter?,
            metadata: [String: String]?
        ) {
            self.vector_store_id = vectorStoreID
            self.name = name
            self.expiresAfter = expiresAfter
            self.metadata = metadata
        }
    }
}

extension OpenAI.APISpecification.RequestBodies {
    struct DeleteVectorStore: Codable {
        enum CodingKeys: String, CodingKey {
            case vector_store_id
        }
        
        /// The ID of the vector store to delete.
        let vector_store_id: String
        
        init(
            vector_store_id: String
        ) {
            self.vector_store_id = vector_store_id
        }
    }
}

// MARK: - Auxiliary

extension OpenAI.APISpecification.RequestBodies.CreateChatCompletion {
    struct ChatFunctionDefinition: Codable, Hashable {
        let name: String
        let description: String
        let parameters: JSONSchema
        
        init(name: String, description: String, parameters: JSONSchema) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
}
