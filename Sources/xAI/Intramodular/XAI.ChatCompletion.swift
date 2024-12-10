//
//  File.swift
//  AI
//
//  Created by Purav Manot on 11/12/24.
//

import Foundation
import OpenAI

extension XAI {
    public final class ChatCompletion: XAI.Object {
        private enum CodingKeys: String, CodingKey {
            case id
            case model
            case createdAt = "created"
            case choices
            case usage
        }
        
        public struct Choice: Codable, Hashable, Sendable {
            public enum FinishReason: String, Codable, Hashable, Sendable {
                case length = "length"
                case stop = "stop"
                case functionCall = "function_call"
            }
            
            public let message: ChatMessage
            public let index: Int
            public let finishReason: FinishReason?
        }
        
        public let id: String
        public let model: XAI.Model
        public let createdAt: Date
        public let choices: [Choice]
        public let usage: Usage
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(forKey: .id)
            self.model = try container.decode(forKey: .model)
            self.createdAt = try container.decode(forKey: .createdAt)
            self.choices = try container.decode(forKey: .choices)
            self.usage = try container.decode(forKey: .usage)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(model, forKey: .model)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(choices, forKey: .choices)
            try container.encode(usage, forKey: .usage)
        }
    }
    
    public final class ChatCompletionChunk: XAI.Object {
        private enum CodingKeys: String, CodingKey {
            case id
            case model
            case createdAt = "created"
            case choices
        }
        
        public struct Choice: Codable, Hashable, Sendable {
            public struct Delta: Codable, Hashable, Sendable {
                public let role: OpenAI.ChatRole?
                public let content: String?
            }
            
            public enum FinishReason: String, Codable, Hashable, Sendable {
                case length = "length"
                case stop = "stop"
            }
            
            public var delta: Delta
            public let index: Int
            public let finishReason: FinishReason?
        }
        
        public let id: String
        public let model: XAI.Model
        public let createdAt: Date
        public let choices: [Choice]
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(forKey: .id)
            self.model = try container.decode(forKey: .model)
            self.createdAt = try container.decode(forKey: .createdAt)
            self.choices = try container.decode(forKey: .choices)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(model, forKey: .model)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(choices, forKey: .choices)
        }
    }
}

extension XAI {
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
                    return XAI.ChatCompletion.self
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

extension XAI {
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

extension XAI {
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
