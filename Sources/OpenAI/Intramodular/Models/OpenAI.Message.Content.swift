//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import NetworkKit

extension OpenAI.Message {
    public enum ContentType: String, Codable, Hashable, Sendable {
        case imageFile = "image_file"
        case text = "text"
    }
    
    public enum Content: Codable, CustomDebugStringConvertible, Hashable, Sendable {
        public struct ImageFile: Codable, Hashable, Sendable {
            public let type: OpenAI.Message.ContentType
            public let imageFile: ImageFileContent
            
            public struct ImageFileContent: Codable, Hashable, Sendable {
                public let fileID: OpenAI.File.ID
            }
        }
        
        public struct Text: Codable, Hashable, Sendable {
            public let type: OpenAI.Message.ContentType
            public let text: TextContent
            
            public struct TextContent: Codable, Hashable, Sendable {
                public let value: String
                public let annotations: [OpenAI.Message.Content.Annotation]
            }
        }
        
        case imageFile(ImageFile)
        case text(Text)
        
        public var debugDescription: String {
            switch self {
                case .imageFile:
                    return "[image]"
                case .text(let text):
                    return text.text.value
            }
        }
    }
}

// MARK: - Conformances

extension OpenAI.Message.Content {
    enum CodingKeys: String, CodingKey {
        case type
        case imageFile = "image_file"
        case text
    }
    
    enum ContentTypeKey: CodingKey {
        case type
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .imageFile(let imageFile):
                try container.encode("image_file", forKey: .type)
                try container.encode(imageFile, forKey: .imageFile)
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: ContentTypeKey.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
            case "image_file":
                let imageFileContainer = try decoder.container(keyedBy: CodingKeys.self)
                let imageFile = try imageFileContainer.decode(ImageFile.self, forKey: .imageFile)
                self = .imageFile(imageFile)
            case "text":
                let text = try Text(from: decoder)
                self = .text(text)
            default:
                throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Invalid type for content")
        }
    }
}

// MARK: - Auxiliary

extension OpenAI.Message.Content {
    public enum AnnotationType: String, Codable, Hashable, Sendable {
        case fileCitation = "file_citation"
        case filePath = "file_path"
    }
    
    public enum Annotation: Codable, Hashable, Sendable {
        case fileCitation(OpenAI.Message.Content.FileCitation)
        case filePath(OpenAI.Message.Content.FilePath)
    }
}

extension OpenAI.Message.Content.Annotation {
    private enum CodingKeys: String, CodingKey {
        case type
        case text
        case fileCitation = "file_citation"
        case filePath = "file_path"
        case startIndex = "start_index"
        case endIndex = "end_index"
    }
    
    private enum AnnotationTypeKey: CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: AnnotationTypeKey.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
            case "file_citation":
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self = .fileCitation(try container.decode(forKey: .fileCitation))
            case "file_path":
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self = .filePath(try container.decode(forKey: .filePath))
            default:
                throw DecodingError.dataCorruptedError(
                    forKey: .type,
                    in: container,
                    debugDescription: "Invalid annotation type."
                )
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
            case .fileCitation(let fileCitation):
                try container.encode("file_citation", forKey: .type)
                try container.encode(fileCitation, forKey: .fileCitation)
            case .filePath(let filePath):
                try container.encode("file_path", forKey: .type)
                try container.encode(filePath, forKey: .filePath)
        }
    }
}

extension OpenAI.Message.Content {
    public struct FileCitation: Codable, Hashable, Sendable {
        public let type: AnnotationType
        public let text: String
        public let fileCitation: _FileCitation
        public let startIndex: Int
        public let endIndex: Int
        
        public struct _FileCitation: Codable, Hashable, Sendable {
            public let fileID: String
            public let quote: String
        }
    }
    
    public struct FilePath: Codable, Hashable, Sendable {
        public let type: OpenAI.Message.Content.AnnotationType
        public let text: String
        public let filePath: _FilePath
        public let startIndex: Int
        public let endIndex: Int
        
        public struct _FilePath: Codable, Hashable, Sendable {
            public let fileID: String
        }
    }
}
