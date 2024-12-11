//
//  _Gemini.ToolConfig.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Foundation

extension _Gemini {
    public struct ToolConfig: Codable {
        public struct FunctionCallingConfig: Codable {
            public enum Mode: String, Codable {
                case auto = "AUTO"
                case none = "NONE"
                case any = "ANY"
            }
            
            public let mode: Mode?
            public let allowedFunctionNames: [String]?
            
            public init(mode: Mode? = nil, allowedFunctionNames: [String]? = nil) {
                self.mode = mode
                self.allowedFunctionNames = allowedFunctionNames
            }
        }
        
        public let functionCallingConfig: FunctionCallingConfig?
        
        public init(functionCallingConfig: FunctionCallingConfig? = nil) {
            self.functionCallingConfig = functionCallingConfig
        }
    }
}
