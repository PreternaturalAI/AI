//
//  _Gemini.GenerationConfig.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

extension _Gemini {
    public struct GenerationConfig: Codable {
        public let maxOutputTokens: Int?
        public let temperature: Double?
        public let topP: Double?
        public let topK: Int?
        public let presencePenalty: Double?
        public let frequencyPenalty: Double?
        public let responseMimeType: String?
        public let responseSchema: ResponseSchema?
        
        public init(
            maxOutputTokens: Int? = nil,
            temperature: Double? = nil,
            topP: Double? = nil,
            topK: Int? = nil,
            presencePenalty: Double? = nil,
            frequencyPenalty: Double? = nil,
            responseMimeType: String? = nil,
            responseSchema: ResponseSchema? = nil
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
    
    public struct ResponseSchema: Codable {
        public let type: SchemaType
        public let items: SchemaObject?
        public let properties: [String: SchemaObject]?
        
        public init(
            type: SchemaType,
            items: SchemaObject? = nil,
            properties: [String: SchemaObject]? = nil
        ) {
            self.type = type
            self.items = items
            self.properties = properties
        }
        
        private enum CodingKeys: String, CodingKey {
            case type
            case items
            case properties
        }
    }
    
    public struct SchemaObject: Codable {
        public let type: SchemaType
        public let properties: [String: SchemaObject]?
        
        public init(
            type: SchemaType,
            properties: [String: SchemaObject]? = nil
        ) {
            self.type = type
            self.properties = properties
        }
    }
    
    public enum SchemaType: String, Codable {
        case array = "ARRAY"
        case object = "OBJECT"
        case string = "STRING"
        case number = "NUMBER"
        case boolean = "BOOLEAN"
    }
}
