//
//  HumeAI.Prompt.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct Prompt: Codable {
        public let id: String
        public let name: String
        public let description: String?
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let versions: [PromptVersion]?
        
        public struct PromptVersion: Codable {
            public let id: String
            public let promptId: String
            public let description: String?
            public let createdOn: Int64
            public let modifiedOn: Int64
            public let content: String
            public let metadata: [String: String]?
        }
    }
}
