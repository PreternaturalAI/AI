//
// Copyright (c) Preternatural AI, Inc.
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
