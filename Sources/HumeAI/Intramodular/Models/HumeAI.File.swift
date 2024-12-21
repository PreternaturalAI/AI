//
// Copyright (c) Preternatural AI, Inc.
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
