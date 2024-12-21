//
// Copyright (c) Preternatural AI, Inc.
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
