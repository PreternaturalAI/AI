//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension _Gemini {
    public struct File: Codable {
        public let createTime: String?
        public let expirationTime: String?
        public let mimeType: String?
        public let name: _Gemini.File.Name?
        public let sha256Hash: String?
        public let sizeBytes: String?
        public let state: State
        public let updateTime: String?
        public let uri: URL
        public let videoMetadata: VideoMetadata?
        
        public enum State: String, Codable {
            case processing = "PROCESSING"
            case active = "ACTIVE"
        }
        
        public struct VideoMetadata: Codable {
            public let videoDuration: String
        }
    }
}

extension _Gemini.File {
    public struct Name: Codable, RawRepresentable {
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
}

// MARK: - Supplementary

extension _Gemini {
    public enum FileSource {
        case localFile(URL)
        case remoteURL(URL)
        case uploadedFile(_Gemini.File)
    }
}
