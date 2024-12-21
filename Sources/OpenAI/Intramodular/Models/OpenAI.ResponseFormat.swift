//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Diagnostics
import LargeLanguageModels
import Swallow

extension OpenAI.ChatCompletion {
    public enum ResponseFormatType: String, Codable, Hashable, Sendable {
        case text
        case jsonObject = "json_object"
        case jsonSchema = "json_schema"
        case unknown
    }
    
    public enum ResponseFormat: Codable, Hashable, Sendable {
        case text
        case jsonObject
        case jsonSchema(JSONSchemaValue)
        case unknown
    }
}

// MARK: - Initializers

extension OpenAI.ChatCompletion.ResponseFormat {
    public init(
        schema: JSONSchema,
        name: String,
        strict: Bool
    ) {
        self = .jsonSchema(
            JSONSchemaValue(
                name: name,
                description: schema.description,
                strict: strict,
                schema: schema
            )
        )
    }
}

// MARK: - Conformances

extension OpenAI.ChatCompletion.ResponseFormat {
    private enum CodingKeys: String, CodingKey {
        case type
        case jsonSchema = "json_schema"
    }
    
    public init(
        from decoder: Decoder
    ) throws {
        if let singleValueContainer = try? decoder.singleValueContainer(), let type: OpenAI.ChatCompletion.ResponseFormatType = try? singleValueContainer.decode(OpenAI.ChatCompletion.ResponseFormatType.self) {
            switch type {
                case .text:
                    self = .text
                case .jsonObject:
                    self = .jsonObject
                default:
                    self = .unknown
            }
            
            return
        }
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let type = try container.decode(OpenAI.ChatCompletion.ResponseFormat.self, forKey: .type)
        
        switch type {
            case .text:
                self = .text
            case .jsonObject:
                self = .jsonObject
            case .jsonSchema:
                let jsonSchema = try container.decode(
                    OpenAI.ChatCompletion.ResponseFormat.JSONSchemaValue.self,
                    forKey: .jsonSchema
                )
                
                self = .jsonSchema(jsonSchema)
            default:
                self = .unknown
        }
    }
    
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .text:
                try container.encode(OpenAI.ChatCompletion.ResponseFormatType.text, forKey: .type)
            case .jsonObject:
                try container.encode(OpenAI.ChatCompletion.ResponseFormatType.jsonObject, forKey: .type)
            case .jsonSchema(let jsonSchema): do {
                try container.encode(OpenAI.ChatCompletion.ResponseFormatType.jsonSchema, forKey: .type)
                try container.encode(jsonSchema, forKey: .jsonSchema)
            }
            case .unknown:
                try container.encode(OpenAI.ChatCompletion.ResponseFormatType.unknown, forKey: .type)
        }
    }
}

// MARK: - Auxiliary

extension OpenAI.ChatCompletion.ResponseFormat {
    public struct JSONSchemaValue: Codable, Hashable, Sendable {
        public let name: String
        public let description: String?
        public let strict: Bool
        public let schema: JSONSchema
                
        public init(
            name: String,
            description: String? = nil,
            strict: Bool,
            schema: JSONSchema
        ) {
            var schema: JSONSchema = schema
            
            if strict {
                assertionFailure("`strict` is currently not supported, this is a bug in the Preternatural SDK and will be fixed soon")
                
                schema.requireAllPropertiesRecursively()
            }
            
            if let additionalProperties = schema.additionalProperties, JSONSchema(from: additionalProperties) != nil {
                assertionFailure("OpenAI currently does not support `additionalProperties`")
            } else {
                schema.disableAdditionalPropertiesRecursively()
            }
            
            self.name = name
            self.description = description
            self.strict = strict
            self.schema = schema
        }
    }
}
