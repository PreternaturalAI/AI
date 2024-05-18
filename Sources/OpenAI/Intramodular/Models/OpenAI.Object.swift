//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public enum ObjectType: String, CaseIterable, Codable, TypeDiscriminator, Sendable {
        case list
        case embedding
        case textCompletion = "text_completion"
        case chatCompletion = "chat.completion"
        case chatCompletionChunk = "chat.completion.chunk"
        case speech = "speech"
        case transcription = "transcription"
        case file = "file"
        case thread = "thread"
        case message = "thread.message"
        case assistant = "assistant"
        case assistantFile = "assistant.file"
        case run = "thread.run"
        case image
        case vectorStore = "vector_store"
        case vectorStoreDeleted = "vector_store.deleted"
        
        public static var _undiscriminatedType: Any.Type? {
            OpenAI.Object.self
        }
        
        public func resolveType() -> Any.Type {
            switch self {
                case .list:
                    return OpenAI.List<Object>.self
                case .embedding:
                    return OpenAI.Embedding.self
                case .textCompletion:
                    return OpenAI.TextCompletion.self
                case .chatCompletion:
                    return OpenAI.ChatCompletion.self
                case .chatCompletionChunk:
                    return OpenAI.ChatCompletionChunk.self
                case .speech:
                    return OpenAI.Speech.self
                case .transcription:
                    return OpenAI.AudioTranscription.self
                case .image:
                    return OpenAI.Image.self
                case .file:
                    return OpenAI.File.self
                case .thread:
                    return OpenAI.Thread.self
                case .message:
                    return OpenAI.Message.self
                case .assistant:
                    return OpenAI.Assistant.self
                case .assistantFile:
                    return OpenAI.AssistantFile.self
                case .run:
                    return OpenAI.Run.self
                case .vectorStore:
                    return OpenAI.VectorStore.self
                case .vectorStoreDeleted:
                    return OpenAI.VectorStore.self
            }
        }
    }
}

extension OpenAI {
    public class Object: Codable, PolymorphicDecodable, TypeDiscriminable, @unchecked Sendable {
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
    }
}
