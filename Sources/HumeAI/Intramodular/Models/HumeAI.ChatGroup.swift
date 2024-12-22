//
//  HumeAI.ChatGroup.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
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
