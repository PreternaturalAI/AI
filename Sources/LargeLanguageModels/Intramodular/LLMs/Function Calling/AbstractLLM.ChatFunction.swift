//
// Copyright (c) Preternatural AI, Inc.
//

import Swallow

extension AbstractLLM {
    /// A function available to a chat-interface LLM.
    public struct ChatFunction: _opaque_DynamicPromptVariable, HashEquatable, @unchecked Sendable {
        public let id: AnyHashable
        public var definition: AbstractLLM.ChatFunctionDefinition
        public var body: (ChatFunctionCall) async throws -> AbstractLLM.ResultOfFunctionCall.FunctionResult
                
        public var promptLiteral: PromptLiteral {
            get throws {
                try _promptLiteral()
            }
        }
                
        public var _runtimeResolvedValue: Self? {
            assertionFailure()
            
            return self
        }
        
        public var _isEmpty: Bool {
            false
        }
        
        public init(
            id: AnyHashable?,
            definition: AbstractLLM.ChatFunctionDefinition,
            body: @escaping (ChatFunctionCall) async throws -> AbstractLLM.ResultOfFunctionCall.FunctionResult
        ) {
            self.id = id ?? AnyHashable(definition.name)
            self.definition = definition
            self.body = body
        }
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(definition)
        }
        
        public func get() throws -> Self {
            throw Never.Reason.unexpected
        }
        
        private func _promptLiteral() throws -> PromptLiteral {
            assertionFailure()
            
            throw Never.Reason.illegal
        }
    }
}

// MARK: Conformances

extension AbstractLLM.ChatFunction: CustomStringConvertible {
    public var description: String {
        "(Chat Function)"
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatFunction {
    public struct Name: Codable, CustomStringConvertible, ExpressibleByStringLiteral, Hashable, Sendable {
        public let rawValue: String
        
        public var description: String {
            rawValue
        }
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public init(stringLiteral value: StringLiteralType) {
            self.init(rawValue: value)
        }
        
        public init(from decoder: any Decoder) throws {
            try self.init(rawValue: String(from: decoder))
        }
        
        public func encode(to encoder: any Encoder) throws {
            try rawValue.encode(to: encoder)
        }
    }
}
