//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import LargeLanguageModels
import Swallow

extension OpenAI {
    public struct ChatMessage: Hashable, Sendable {
        public typealias ID = String
        
        public let id: ID
        public let role: ChatRole
        public var body: ChatMessageBody
                
        public init(
            id: ID? = nil,
            role: ChatRole,
            body: ChatMessageBody
        ) {
            switch body {
                case .text:
                    assert(role != .function)
                case .content:
                    assert(role != .function)
                case .functionCall:
                    assert(role == .assistant)
                case .functionInvocation:
                    assert(role == .function)
            }
            
            self.id = id ?? UUID().stringValue // FIXME: !!!
            self.role = role
            self.body = body
        }
    }
    
    public struct ChatFunctionDefinition: Codable, Hashable, Sendable {
        public let name: String
        public let description: String
        public let parameters: JSONSchema
        
        public init(name: String, description: String, parameters: JSONSchema) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
    
    public enum FunctionCallingStrategy: Codable, Hashable, Sendable {
        enum CodingKeys: String, CodingKey {
            case none = "none"
            case auto = "auto"
            case function = "name"
        }
        
        case none
        case auto
        case function(String)
        
        public init(from decoder: Decoder) throws {
            switch try decoder._determineContainerKind() {
                case .singleValue:
                    let rawValue = try decoder.singleValueContainer().decode(String.self)
                    
                    switch rawValue {
                        case CodingKeys.none.rawValue:
                            self = .none
                        case CodingKeys.auto.rawValue:
                            self = .auto
                        default:
                            throw DecodingError.dataCorrupted(.init(codingPath: []))
                    }
                case .keyed:
                    let container = try decoder.container(keyedBy: CodingKeys.self)
                    
                    self = try .function(container.decode(String.self, forKey: .function))
                default:
                    throw DecodingError.dataCorrupted(.init(codingPath: []))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            switch self {
                case .none:
                    var container = encoder.singleValueContainer()
                    
                    try container.encode(CodingKeys.none.rawValue)
                case .auto:
                    var container = encoder.singleValueContainer()
                    
                    try container.encode(CodingKeys.auto.rawValue)
                case .function(let name):
                    var container = encoder.container(keyedBy: CodingKeys.self)
                    
                    try container.encode(name, forKey: .function)
            }
        }
    }
}

// MARK: - Conformances

extension OpenAI.ChatMessage: AbstractLLM.ChatMessageConvertible {
    public func __conversion() throws -> AbstractLLM.ChatMessage {
        .init(
            id: .init(rawValue: id),
            role: try role.__conversion(),
            content: try PromptLiteral(from: self)
        )
    }
}

extension OpenAI.ChatMessage: Codable {
    public enum CodingKeys: CodingKey {
        case id
        case role
        case content
        case name
        case functionCall
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().stringValue // FIXME
        self.role = try container.decode(OpenAI.ChatRole.self, forKey: .role)
        
        switch role {
            case .function:
                self.body = .functionInvocation(
                    .init(
                        name: try container.decode(String.self, forKey: .name),
                        response: try container.decode(String.self, forKey: .name)
                    )
                )
            case .assistant:
                if let functionCall = try container.decodeIfPresent(OpenAI.ChatMessageBody.FunctionCall.self, forKey: .functionCall) {
                    self.body = .functionCall(functionCall)
                } else {
                    self.body = try .content(container.decode(String.self, forKey: .content))
                }
            default:
                self.body = try .content(container.decode(String.self, forKey: .content))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(role, forKey: .role)
        
        switch body {
            case .text(let content):
                try container.encode(content, forKey: .content)
            case .content(let content):
                try container.encode(content, forKey: .content)
            case .functionCall(let call):
                try _tryAssert(role == .assistant)
                
                try container.encode(call, forKey: .functionCall)
                try container.encodeNil(forKey: .content)
            case .functionInvocation(let invocation):
                try _tryAssert(role == .function)
                
                try container.encode(invocation.name, forKey: .name)
                try container.encode(invocation.response, forKey: .content)
        }
    }
}

// MARK: - Initializers

extension OpenAI.ChatMessage {
    public init(
        id: ID? = nil,
        role: OpenAI.ChatRole,
        body: String
    ) {
        self.init(
            id: id,
            role: role,
            body: .content(body)
        )
    }
    
    public init(
        role: OpenAI.ChatRole,
        content: String
    ) {
        self.init(
            role: role,
            body: content
        )
    }

    public static func system(
        _ content: String
    ) -> Self {
        Self(id: UUID().stringValue, role: .system, body: .content(content))
    }
    
    public static func user(
        _ content: String
    ) -> Self {
        Self(id: UUID().stringValue, role: .user, body: .content(content))
    }
}
