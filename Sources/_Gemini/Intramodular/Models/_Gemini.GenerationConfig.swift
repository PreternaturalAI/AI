//
//  _Gemini.GenerationConfig.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Foundation

extension _Gemini {
    public struct GenerationConfiguration: Codable {
        public let maxOutputTokens: Int?
        public let temperature: Double?
        public let topP: Double?
        public let topK: Int?
        public let presencePenalty: Double?
        public let frequencyPenalty: Double?
        public let responseMimeType: String?
        public let responseSchema: SchemaObject?
        
        public init(
            maxOutputTokens: Int? = nil,
            temperature: Double? = nil,
            topP: Double? = nil,
            topK: Int? = nil,
            presencePenalty: Double? = nil,
            frequencyPenalty: Double? = nil,
            responseMimeType: String? = nil,
            responseSchema: SchemaObject? = nil
        ) {
            self.maxOutputTokens = maxOutputTokens
            self.temperature = temperature
            self.topP = topP
            self.topK = topK
            self.presencePenalty = presencePenalty
            self.frequencyPenalty = frequencyPenalty
            self.responseMimeType = responseMimeType
            self.responseSchema = responseSchema
        }
    }
    
    public enum SchemaType: String, Codable {
        case array = "ARRAY"
        case object = "OBJECT"
        case string = "STRING"
        case number = "NUMBER"
        case boolean = "BOOLEAN"
    }

    public indirect enum SchemaObject {
        case object(properties: [String: SchemaObject])
        case array(items: SchemaObject)
        case string
        case number
        case boolean
        
        public var type: SchemaType {
            switch self {
                case .object:
                    return .object
                case .array:
                    return .array
                case .string:
                    return .string
                case .number:
                    return .number
                case .boolean:
                    return .boolean
            }
        }
    }
}

// MARK: - Conformances

extension _Gemini.SchemaObject: Codable {
    private enum CodingKeys: String, CodingKey {
        case type
        case properties
        case items
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        switch self {
            case .object(let properties):
                try container.encode(properties, forKey: .properties)
            case .array(let items):
                try container.encode(items, forKey: .items)
            case .string, .number, .boolean:
                break
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(_Gemini.SchemaType.self, forKey: .type)
        
        switch type {
            case .object:
                let properties = try container.decode([String: _Gemini.SchemaObject].self, forKey: .properties)
                self = .object(properties: properties)
            case .array:
                let items = try container.decode(_Gemini.SchemaObject.self, forKey: .items)
                self = .array(items: items)
            case .string:
                self = .string
            case .number:
                self = .number
            case .boolean:
                self = .boolean
        }
    }
}
