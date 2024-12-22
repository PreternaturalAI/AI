//
//  HumeAI.Prompt.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct Prompt: Codable {
        public let id: String
        public let version: Int
        public let versionType: String
        public let name: String
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let text: String
        public let versionDescription: String?
        
        public struct PromptVersion: Codable {
            public let id: String
            public let version: Int
            public let versionType: String
            public let name: String
            public let createdOn: Int64
            public let modifiedOn: Int64
            public let text: String
            public let versionDescription: String?
        }
    }
}
