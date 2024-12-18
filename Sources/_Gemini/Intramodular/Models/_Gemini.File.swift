//
//  _Gemini.File.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Foundation

extension _Gemini {
    public struct File: Codable {
        public let createTime: String?
        public let expirationTime: String?
        public let mimeType: String?
        public let name: String?
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
