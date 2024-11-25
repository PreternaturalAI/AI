//
//  HumeAI.Tool.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct Tool: Codable {
        public let id: String
        public let name: String
        public let description: String?
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let versions: [ToolVersion]?
        
        public struct ToolVersion: Codable {
            public let id: String
            public let toolId: String
            public let description: String?
            public let createdOn: Int64
            public let modifiedOn: Int64
            public let parameters: String
            public let fallbackContent: String?
        }
    }
}
