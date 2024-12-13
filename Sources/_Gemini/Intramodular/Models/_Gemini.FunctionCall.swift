//
//  _Gemini.FunctionCall.swift
//  AI
//
//  Created by Jared Davidson on 12/13/24.
//

import Foundation

extension _Gemini {
    public struct FunctionCall: Codable, Equatable {
        public let name: String
        public let args: [String: String]
        
        public init(name: String, args: [String: String]) {
            self.name = name
            self.args = args
        }
    }
    
    public struct FunctionDefinition: Codable, Equatable {
        public let name: String
        public let description: String
        public let parameters: ParameterSchema?
        
        public init(name: String, description: String, parameters: ParameterSchema? = nil) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
    
    public struct ParameterSchema: Codable, Equatable {
        public let type: String
        public let description: String?
        public let properties: [String: ParameterSchema]?
        public let required: [String]?
        
        public init(
            type: String,
            description: String? = nil,
            properties: [String: ParameterSchema]? = nil,
            required: [String]? = nil
        ) {
            self.type = type.uppercased()
            self.description = description
            self.properties = properties
            self.required = required
        }
    }
    
    public struct FunctionCallingConfig: Codable, Equatable {
        public enum Mode: String, Codable {
            case auto = "AUTO"
            case any = "ANY"
            case none = "NONE"
        }
        
        public let mode: Mode
        public let allowedFunctionNames: [String]?
        
        public init(mode: Mode, allowedFunctionNames: [String]? = nil) {
            self.mode = mode
            self.allowedFunctionNames = allowedFunctionNames
        }
    }
    
    public struct ToolConfig: Codable, Equatable {
        public let functionCallingConfig: FunctionCallingConfig?
        
        public init(functionCallingConfig: FunctionCallingConfig? = nil) {
            self.functionCallingConfig = functionCallingConfig
        }
    }
}
