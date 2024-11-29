//
//  HumeAI.FileInput.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct FileInput: Codable {
        public let url: String
        public let mimeType: String
        public let metadata: [String: String]?
        
        public init(url: String, mimeType: String, metadata: [String: String]? = nil) {
            self.url = url
            self.mimeType = mimeType
            self.metadata = metadata
        }
    }
}
