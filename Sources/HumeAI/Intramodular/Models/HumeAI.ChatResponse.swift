//
// Copyright (c) Preternatural AI, Inc.
//

extension HumeAI {
    public struct ChatResponse {
        public let id: String
        public let created: Int64
        public let choices: [Choice]
        public let usage: Usage
        
        public struct Choice {
            public let index: Int
            public let message: Message
            public let finishReason: String?
            
            public struct Message {
                public let role: String
                public let content: String
            }
        }
        
        public struct Usage {
            public let promptTokens: Int
            public let completionTokens: Int
            public let totalTokens: Int
        }
    }
}
