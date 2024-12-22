//
//  HumeAI.ChatEvent.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct ChatEvent: Codable {
         public let id: String
         public let chatId: String
         public let type: String
         public let content: String
         public let createdOn: Int64
         public let audioUrl: String?
         public let metadata: [String: String]?
     }
}
