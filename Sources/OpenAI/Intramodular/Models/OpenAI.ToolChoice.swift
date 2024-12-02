//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swift

extension OpenAI {
    public enum ToolChoice: Codable {
        case none
        case auto
        case required
        case tool(OpenAI.ToolChoice.ToolValue)
        
        public enum ToolChoiceType: String, Codable, Hashable {
            case none
            case auto
            case required
            case tool
        }
        
        public enum ToolValue: Codable {
            case function(String)
            
            public struct FunctionDetails: Codable {
                var name: String
                
                public init(name: String) {
                    self.name = name
                }
            }
        }
    }
}

// MARK: - Conformances

extension OpenAI.ToolChoice {
    public enum CodingKeys: String, CodingKey {
        case type, toolWrapper
    }
    
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(ToolChoiceType.self, forKey: .type)
        
        switch type {
            case .none:
                self = .none
            case .auto:
                self = .auto
            case .required:
                self = .required
            case .tool:
                self = .tool(try container.decode(OpenAI.ToolChoice.ToolValue.self, forKey: .toolWrapper))
        }
    }
    
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .none:
                try container.encode(ToolChoiceType.none, forKey: .type)
            case .auto:
                try container.encode(ToolChoiceType.auto, forKey: .type)
            case .required:
                try container.encode(ToolChoiceType.required, forKey: .type)
            case .tool(let toolWrapper):
                try container.encode(ToolChoiceType.tool, forKey: .type)
                try container.encode(toolWrapper, forKey: .toolWrapper)
        }
    }
}

extension OpenAI.ToolChoice.ToolValue {
    public enum CodingKeys: String, CodingKey {
        case type
        case function
    }
    
    public init(
        from decoder: Decoder
    ) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
            case "function":
                let functionDetails = try container.decode(FunctionDetails.self, forKey: .function)
                
                self = .function(functionDetails.name)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type value")
        }
    }
    
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .function(let name):
                try container.encode("function", forKey: .type)
                try container.encode(FunctionDetails(name: name), forKey: .function)
        }
    }
}
