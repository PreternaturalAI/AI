//
//  HumeAI.Config.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct Config: Codable {
        public let id: String
        public let name: String
        public let description: String?
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let versions: [ConfigVersion]?
        
        public struct ConfigVersion: Codable {
            public let id: String
            public let configId: String
            public let description: String?
            public let createdOn: Int64
            public let modifiedOn: Int64
            public let settings: [String: String]
        }
    }
}
