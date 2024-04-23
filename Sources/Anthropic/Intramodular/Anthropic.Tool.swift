//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

extension Anthropic {
    public struct Tool: Codable, Hashable, Sendable {
        public let name: String
        public let description: String
        public let inputSchema: JSONSchema
    }
}

// MARK: - Auxiliary

extension Anthropic.Tool {
    package init(_from function: AbstractLLM.ChatFunctionDefinition) throws {
        self.init(
            name: function.name,
            description: function.context,
            inputSchema: function.parameters
        )
    }
}
