//
//  HumeAI.File.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct File: Codable {
        public let id: String
        public let name: String
        public let size: Int
        public let mimeType: String
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let metadata: [String: String]?
    }
}
