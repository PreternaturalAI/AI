//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public enum ObjectType: String, CaseIterable, Codable, TypeDiscriminator, Sendable {
        case assistant = "assistant"
        case assistantFile = "assistant.file"
        case chatCompletion = "chat.completion"
        case chatCompletionChunk = "chat.completion.chunk"
        case embedding = "embedding"
        case file = "file"
        case image = "image"
        case list
        case message = "thread.message"
        case model = "model"
        case run = "thread.run"
        case speech = "speech"
        case thread = "thread"
        case textCompletion = "text_completion"
        case transcription = "transcription"
        case vectorStore = "vector_store"
        case vectorStoreDeleted = "vector_store.deleted"
        
        public static var _undiscriminatedType: Any.Type? {
            OpenAI.Object.self
        }
        
        public func resolveType() -> Any.Type {
            switch self {
                case .assistant:
                    return OpenAI.Assistant.self
                case .assistantFile:
                    return OpenAI.AssistantFile.self
                case .embedding:
                    return OpenAI.Embedding.self
                case .file:
                    return OpenAI.File.self
                case .chatCompletion:
                    return OpenAI.ChatCompletion.self
                case .chatCompletionChunk:
                    return OpenAI.ChatCompletionChunk.self
                case .image:
                    return OpenAI.Image.self
                case .list:
                    return OpenAI.List<Object>.self
                case .message:
                    return OpenAI.Message.self
                case .model:
                    return OpenAI.ModelObject.self
                case .run:
                    return OpenAI.Run.self
                case .speech:
                    return OpenAI.Speech.self
                case .textCompletion:
                    return OpenAI.TextCompletion.self
                case .thread:
                    return OpenAI.Thread.self
                case .transcription:
                    return OpenAI.AudioTranscription.self
                case .vectorStore:
                    return OpenAI.VectorStore.self
                case .vectorStoreDeleted:
                    return OpenAI.VectorStore.self
            }
        }
    }
}

extension OpenAI {
    public class Object: Codable, PolymorphicDecodable, TypeDiscriminable {
        private enum CodingKeys: String, CodingKey {
            case type = "object"
        }
        
        public let type: ObjectType
        
        public var typeDiscriminator: ObjectType {
            type
        }
        
        public init(type: ObjectType) {
            self.type = type
        }
        
        public required init(
            from decoder: Decoder
        ) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            let type = try container.decodeIfPresent(ObjectType.self, forKey: .type)
            
            if let type {
                self.type = type
            } else if Self.self is OpenAI.AnyList.Type {
                self.type = .list
            } else {
                self.type = try ObjectType.allCases.firstAndOnly(where: { $0.resolveType() == Self.self }).unwrap()
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(type, forKey: .type)
        }
    }
}

extension OpenAI {
    public struct Usage: Codable, Hashable, Sendable {
        public let promptTokens: Int
        public let completionTokens: Int?
        public let totalTokens: Int
        public let promptTokensDetails: PromptTokensDetails?
        public let completionTokensDetails: CompletionTokensDetails?
    }
    
    public struct PromptTokensDetails: Codable, Hashable, Sendable {
        public let cachedTokens: Int?
    }
    
    public struct CompletionTokensDetails: Codable, Hashable, Sendable {
        public let reasoningTokens: Int?
    }
}
