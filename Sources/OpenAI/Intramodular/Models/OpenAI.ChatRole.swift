//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import LargeLanguageModels
import Swallow

extension OpenAI {
    public enum ChatRole: String, Codable, Hashable, Sendable {
        case system
        case user
        case assistant
        case function
        
        public init(from role: AbstractLLM.ChatRole) {
            switch role {
                case .system:
                    self = .system
                case .user:
                    self = .user
                case .assistant:
                    self = .assistant
                case .other(.function):
                    self = .function
            }
        }
        
        public func __conversion() throws -> AbstractLLM.ChatRole {
            switch self {
                case .system:
                    return .system
                case .user:
                    return .user
                case .assistant:
                    return .assistant
                case .function:
                    return .other(.function)
            }
        }
    }
}
