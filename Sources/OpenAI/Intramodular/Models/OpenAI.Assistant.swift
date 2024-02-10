//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public enum ToolType: String, CaseIterable, Codable, Hashable, Sendable {
        case codeInterpreter = "code_interpreter"
        case retrieval
        case function
    }
    
    public struct Tool: Codable, Hashable, Sendable {
        public let type: ToolType
        public let function: OpenAI.ChatFunctionDefinition?
        
        private init(
            type: ToolType,
            function: OpenAI.ChatFunctionDefinition?
        ) {
            self.type = type
            self.function = function
            
            if function != nil {
                assert(type == .function)
            }
        }
        
        public static var codeInterpreter: Self {
            Self(type: .codeInterpreter, function: nil)
        }
        
        public static var retrieval: Self {
            Self(type: .retrieval, function: nil)
        }
        
        public static func function(
            _ function: OpenAI.ChatFunctionDefinition
        ) -> Self {
            Self(type: .function, function: function)
        }
    }
    
    public struct ToolCall: Codable, Hashable, Sendable {
        public let index: Int?
        public let id: String?
        public let type: ToolType?
        public let function: ChatMessageBody.FunctionCall
        
        public init(
            index: Int? = nil,
            id: String?,
            type: ToolType = .function,
            function: ChatMessageBody.FunctionCall
        ) {
            self.index = index
            self.id = id
            self.type = type
            self.function = function
        }
    }
}

extension OpenAI {
    public final class Assistant: OpenAI.Object {
        private enum CodingKeys: String, CodingKey {
            case id
            case object
            case createdAt = "created_at"
            case name
            case description
            case model
            case instructions
            case tools
            case fileIdentifiers = "file_ids"
            case metadata
        }
        
        public let id: String
        public let createdAt: Int
        public let name: String?
        public let description: String?
        public let model: OpenAI.Model
        public let instructions: String?
        public let tools: [Tool]
        public let fileIdentifiers: [String]
        public let metadata: [String: String]
        
        public init(
            id: String,
            createdAt: Int,
            name: String?,
            description: String?,
            model: OpenAI.Model,
            instructions: String?,
            tools: [Tool],
            fileIdentifiers: [String],
            metadata: [String : String]
        ) {
            self.id = id
            self.createdAt = createdAt
            self.name = name
            self.description = description
            self.model = model
            self.instructions = instructions
            self.tools = tools
            self.fileIdentifiers = fileIdentifiers
            self.metadata = metadata
            
            super.init(type: .assistantFile)
        }
        
        public required init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.id = try container.decode(forKey: .id)
            self.createdAt = try container.decode(forKey: .createdAt)
            self.name = try container.decode(forKey: .name)
            self.description = try container.decode(forKey: .description)
            self.model = try container.decode(forKey: .model)
            self.instructions = try container.decode(forKey: .instructions)
            self.tools = try container.decode(forKey: .tools)
            self.fileIdentifiers = try container.decode(forKey: .fileIdentifiers)
            self.metadata = try container.decode(forKey: .metadata)
            
            try super.init(from: decoder)
        }
        
        public override func encode(to encoder: Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(id, forKey: .id)
            try container.encode(createdAt, forKey: .createdAt)
            try container.encode(name, forKey: .name)
            try container.encode(description, forKey: .description)
            try container.encode(model, forKey: .model)
            try container.encode(instructions, forKey: .instructions)
            try container.encode(tools, forKey: .tools)
            try container.encode(fileIdentifiers, forKey: .fileIdentifiers)
            try container.encode(metadata, forKey: .metadata)
        }
    }
}
