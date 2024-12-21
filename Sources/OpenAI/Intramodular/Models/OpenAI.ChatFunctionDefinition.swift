//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Diagnostics
import LargeLanguageModels
import Swallow

extension OpenAI {
    public struct ToolName: Codable, Hashable, RawRepresentable, Sendable {
        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(from decoder: any Decoder) throws {
            rawValue = try String(from: decoder)
        }
        
        public func encode(to encoder: any Encoder) throws {
            try rawValue.encode(to: encoder)
        }
    }

    public struct ChatFunctionDefinition: Codable, Hashable, Sendable {
        public let name: OpenAI.ToolName
        public let description: String
        public let parameters: JSONSchema
        
        public init(
            name: OpenAI.ToolName,
            description: String,
            parameters: JSONSchema
        ) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
        
        public init(
            name: String,
            description: String,
            parameters: JSONSchema
        ) {
            self.init(
                name: OpenAI.ToolName(
                    rawValue: name
                ),
                description: description,
                parameters: parameters
            )
        }
    }
}
