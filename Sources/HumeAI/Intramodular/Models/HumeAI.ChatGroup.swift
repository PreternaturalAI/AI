//
// Copyright (c) Preternatural AI, Inc.
//

extension HumeAI {
    public struct ChatGroup {
        public let id: String
        public let name: String
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let chats: [Chat]?
    }
}
