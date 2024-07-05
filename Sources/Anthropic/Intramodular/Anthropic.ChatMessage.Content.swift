//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import Swallow
import UniformTypeIdentifiers

extension Anthropic.ChatMessage {
    public enum Content: Codable, Hashable, Sequence, Sendable {
        case text(String)
        case list([Anthropic.ChatMessage.Content.ContentObject])
        
        public func makeIterator() -> Array<Anthropic.ChatMessage.Content.ContentObject>.Iterator {
            switch self {
                case .text(let text):
                    return [.text(text)].makeIterator()
                case .list(let content):
                    return content.makeIterator()
            }
        }
        
        public init(from decoder: Decoder) throws {
            if let text = try? String(from: decoder) {
                self = .text(text)
            } else {
                self = try .list(.init(from: decoder))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            switch self {
                case .text(let text):
                    try container.encode(text)
                case .list(let objects):
                    try container.encode(objects)
            }
        }
    }
}

extension Anthropic.ChatMessage.Content {
    public enum ContentObjectType: String, Codable, Hashable, Sendable {
        case text
        case image
        case toolUse = "tool_use"
        case toolResult = "tool_result"
    }
    
    public enum ContentObject: Codable, Hashable, Sendable {
        public typealias ContentObjectType = Anthropic.ChatMessage.Content.ContentObjectType
        public typealias ImageSourceType = Anthropic.ChatMessage.Content.ImageSourceType
        public typealias ImageSource = Anthropic.ChatMessage.Content.ImageSource
        
        case text(String)
        case image(ImageSource)
        case toolUse(ToolUse)
        case toolResult(ToolResult)
    }
}

// MARK: - Conformances

extension Anthropic.ChatMessage.Content.ContentObject {
    private enum CodingKeys: String, CodingKey {
        case type
        case source
        case text
        case id
        case name
        case input
        case toolUseId = "tool_use_id"
        case content
    }
    
    public init(from decoder: any Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type: ContentObjectType = try container.decode(ContentObjectType.self, forKey: .type)
            
            switch type {
                case .text:
                    let text = try container.decode(String.self, forKey: .text)
                    self = .text(text)
                case .image:
                    let source = try container.decode(ImageSource.self, forKey: .source)
                    self = .image(source)
                case .toolUse:
                    self = .toolUse(try Anthropic.ChatMessage.Content.ToolUse(from: decoder))
                case .toolResult:
                    self = .toolResult(try Anthropic.ChatMessage.Content.ToolResult(from: decoder))
            }
        } catch {
            if let text = try? String(from: decoder) {
                self = .text(text)
            } else {
                throw error
            }
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .text(let text):
                try container.encode(ContentObjectType.text, forKey: .type)
                try container.encode(text, forKey: .text)
            case .image(let source):
                try container.encode(ContentObjectType.image, forKey: .type)
                try container.encode(source, forKey: .source)
            case .toolUse(let use):
                try container.encode(ContentObjectType.toolUse, forKey: .type)
                
                try use.encode(to: encoder)
            case .toolResult(let result):
                try container.encode(ContentObjectType.toolResult, forKey: .type)
                
                try result.encode(to: encoder)
        }
    }
}

// MARK: - Auxiliary

extension Anthropic.ChatMessage.Content {
    public struct ToolUse: Codable, Hashable, Sendable {
        public let id: String
        public let name: String
        public var input: [String: AnyCodable]?
        
        public init(
            id: String,
            name: String,
            input: [String : AnyCodable]? = nil
        ) {
            self.id = id
            self.name = name
            self.input = input
        }
    }
    
    public struct ToolResult: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
            case toolUseID = "tool_use_id"
        }
        
        public let toolUseID: String
        public var content: String?
        
        public init(toolUseID: String, content: String? = nil) {
            self.toolUseID = toolUseID
            self.content = content
        }
    }
    
    public enum ImageSourceType: String, Codable, Hashable, Sendable {
        case base64
    }
    
    public struct ImageSource: Codable, Hashable, Sendable {
        public enum MediaType: String, Codable, Hashable, Sendable {
            case jpeg = "image/jpeg"
            case png = "image/png"
            case gif = "image/gif"
            case webp = "image/webp"
            
            init(from string: String) throws {
                let fileType: _MediaAssetFileType = try _MediaAssetFileType(rawValue: string).unwrap()
                
                self = try (Self(rawValue: fileType.mimeType) ?? Self(rawValue: fileType.mimeType.lowercased())).unwrap()
            }
        }
        
        public let type: ImageSourceType
        public let mediaType: MediaType
        @Base64EncodedData
        public var data: Data
        
        public init(
            type: ImageSourceType,
            mediaType: MediaType,
            data: Data
        ) throws {
            self.type = type
            self.mediaType = mediaType
            self.data = data
        }
        
        public init(
            type: ImageSourceType,
            mediaType: String,
            data: Data
        ) throws {
            try self.init(type: type, mediaType: try MediaType(from: mediaType), data: data)
        }
        
        public init(url: Base64DataURL) throws {
            try self.init(
                type: .base64,
                mediaType: url.mimeType,
                data: url.data
            )
        }
        
        public init(url: URL) async throws {
            do {
                let dataURL: Base64DataURL
                
                if url.isWebURL {
                    TODO.unimplemented
                } else {
                    dataURL = try Base64DataURL(url: url)
                }
                
                try self.init(url: dataURL)
            } catch {
                throw error
            }
        }
    }
}
