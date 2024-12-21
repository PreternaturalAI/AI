//
// Copyright (c) Preternatural AI, Inc.
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
            let id: String
            let version: Int
            let toolId: String?
            let description: String?
            let createdOn: Int64
            let modifiedOn: Int64
        }
    }
}
