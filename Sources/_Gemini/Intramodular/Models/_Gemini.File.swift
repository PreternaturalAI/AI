//
//  _Gemini.File.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Foundation

extension _Gemini {
    
    public struct File: Codable, Hashable {
        public let createTime: String?
        public let expirationTime: String?
        public let mimeType: String?
        public let name: _Gemini.File.Name
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
        
        public struct VideoMetadata: Codable, Hashable {
            public let videoDuration: String
        }
    }
    
    public struct FileList: Codable, Hashable {
        public let files: [_Gemini.File]?
        // A token that can be sent as a pageToken into a subsequent files.list call.
        public let nextPageToken: String?
    }
}

extension _Gemini.File {
    public struct Name: Codable, RawRepresentable, Hashable {
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
