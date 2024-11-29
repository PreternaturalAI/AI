

extension xAI {
    public enum ToolType: String, CaseIterable, Codable, Hashable, Sendable {
        /* Currently, only functions are supported as a tool. */
        case function
    }
    
    public struct Tool: Codable, Hashable, Sendable {
        public let type: ToolType
        public let function: xAI.ChatFunctionDefinition?
        
        private init(
            type: ToolType,
            function: xAI.ChatFunctionDefinition?
        ) {
            self.type = type
            self.function = function
            
            if function != nil {
                assert(type == .function)
            }
        }
        
        public static func function(
            _ function: xAI.ChatFunctionDefinition
        ) -> Self {
            Self(type: .function, function: function)
        }
    }
    
    public struct ToolCall: Codable, Hashable, Sendable {
        public let index: Int?
        public let id: String?
        public let type: ToolType?
        public let function: ChatMessageBody.FunctionCall
        
        public init(
            index: Int? = nil,
            id: String?,
            type: ToolType = .function,
            function: ChatMessageBody.FunctionCall
        ) {
            self.index = index
            self.id = id
            self.type = type
            self.function = function
        }
    }
}

