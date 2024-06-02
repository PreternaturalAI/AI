//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import NetworkKit
import Swallow

extension Anthropic.API {
    public enum RequestBodies: _StaticSwift.Namespace {
        
    }
}

extension Anthropic.API.RequestBodies {
    public struct CreateMessage: Codable {
        public enum CodingKeys: String, CodingKey {
            case model
            case messages
            case tools
            case system
            case maxTokens = "max_tokens"
            case temperature
            case topP = "top_p"
            case topK = "top_k"
            case stopSequences = "stop_sequences"
            case stream
            case metadata
        }
        
        public var model: Anthropic.Model
        public var messages: [Anthropic.ChatMessage]
        public let tools: [Anthropic.Tool]
        public var system: String?
        public var maxTokens: Int
        public var temperature: Double?
        public var topP: Double?
        public var topK: UInt?
        public var stopSequences: [String]?
        public var stream: Bool?
        public var metadata: Metadata?
        
        public struct Metadata: Codable, Hashable, Sendable {
            public enum CodingKeys: String, CodingKey {
                case userID = "user_id"
            }
            
            public var userID: String
            
            public init(userID: String) {
                self.userID = userID
            }
        }
        
        public init(
            model: Anthropic.Model,
            messages: [Anthropic.ChatMessage],
            tools: [Anthropic.Tool],
            system: String?,
            maxTokens: Int,
            temperature: Double?,
            topP: Double?,
            topK: UInt?,
            stopSequences: [String]?,
            stream: Bool? ,
            metadata: Metadata?
        ) {
            self.model = model
            self.messages = messages
            self.tools = tools
            self.system = system
            self.maxTokens = maxTokens
            self.temperature = temperature
            self.topP = topP
            self.topK = topK
            self.stopSequences = stopSequences
            self.stream = stream
            self.metadata = metadata
        }
    }
    public struct Complete: Codable, Hashable, Sendable {
        public var prompt: String
        public var model: Anthropic.Model
        public var maxTokensToSample: Int
        public var stopSequences: [String]?
        public var stream: Bool?
        public var temperature: Double?
        public var topK: Int?
        public var topP: Double?
        
        public init(
            prompt: String,
            model: Anthropic.Model,
            maxTokensToSample: Int,
            stopSequences: [String]?,
            stream: Bool?,
            temperature: Double?,
            topK: Int?,
            topP: Double?
        ) {
            self.prompt = prompt
            self.model = model
            self.maxTokensToSample = maxTokensToSample
            self.stopSequences = stopSequences
            self.stream = stream
            self.temperature = temperature
            self.topK = topK
            self.topP = topP
        }
    }
}

extension Anthropic.API.ResponseBodies {
    public struct Complete: Codable, Hashable, Sendable {
        public enum StopReason: String, Codable, Hashable, Sendable {
            case maxTokens = "max_tokens"
            case stopSequence = "stop_sequence"
        }
        
        public var completion: String
        public let stopReason: StopReason
        public let stop: String?
    }
    
    public struct CreateMessage: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case id
            case model
            case type
            case role
            case content
            case stopReason
            case stopSequence
            case usage
        }
        
        public enum StopReason: String, Codable, Hashable, Sendable {
            case endTurn = "end_turn"
            case maxTokens = "max_tokens"
            case stopSequence = "stop_sequence"
            
            public func __conversion() -> AbstractLLM.ChatCompletion.StopReason {
                switch self {
                    case .endTurn:
                        return .endTurn
                    case .maxTokens:
                        return .maxTokens
                    case .stopSequence:
                        return .stopSequence
                }
            }
        }
        
        public let id: String
        public let model: Anthropic.Model
        public let type: String?
        public let role: Anthropic.ChatMessage.Role
        public let content: [Content]
        public let stopReason: StopReason?
        public let stopSequence: String?
        public let usage: Usage
        
        public enum ContentType: String, Codable, Hashable, Sendable {
            case image // FIXME: Unimplemented
            case text
        }
        
        public struct Content: Codable, Hashable, Sendable {
            public let type: ContentType
            public let text: String
        }
        
        public struct Usage: Codable, Hashable, Sendable {
            public let inputTokens: Int
            public let outputTokens: Int
        }
    }
    
    public struct CreateMessageStream: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case type
            case index
            case message
            case delta
            case contentBlock
        }
        
        public struct Delta: Codable, Hashable, Sendable {
            public let type: String?
            public let text: String?
            public let stopReason: String?
            public let stopSequence: String?
        }
        
        public let type: String
        public let index: Int?
        public let message: CreateMessage?
        public let delta: Delta?
        public let contentBlock: Delta?
    }
}
