//
//  _Gemini.Tool.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Foundation

extension _Gemini {
    public struct Tool: Codable {
        public let functionDeclarations: [FunctionDeclaration]?
        public let codeExecution: CodeExecution?
        
        public init(
            functionDeclarations: [FunctionDeclaration]? = nil,
            codeExecution: CodeExecution? = nil
        ) {
            self.functionDeclarations = functionDeclarations
            self.codeExecution = codeExecution
        }
        
        public struct FunctionDeclaration: Codable {
            public let name: String
            public let description: String
            public let parameters: [String: Schema]?
            
            public init(
                name: String,
                description: String,
                parameters: [String: Schema]? = nil
            ) {
                self.name = name
                self.description = description
                self.parameters = parameters
            }
            
            public struct Schema: Codable {
                public let type: String
                public let format: String?
                
                public init(type: String, format: String? = nil) {
                    self.type = type
                    self.format = format
                }
            }
        }
        
        public struct CodeExecution: Codable {
            public let language: String
            public let code: String
            
            public init(language: String, code: String) {
                self.language = language
                self.code = code
            }
        }
    }
}
