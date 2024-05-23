//
// Copyright (c) Vatsal Manot
//

import Swallow

extension AbstractLLM {
    /// A function available to a chat-interface LLM.
    public struct ChatFunction: CustomStringConvertible, _opaque_DynamicPromptVariable, HashEquatable, @unchecked Sendable {
        public let id: AnyHashable
        public let definition: AbstractLLM.ChatFunctionDefinition
        public let body: (ChatFunctionCall) async throws -> AbstractLLM.ChatFunctionInvocation.FunctionResult
        
        public var description: String {
            "(Chat Function)"
        }
        
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
            body: @escaping (ChatFunctionCall) async throws -> AbstractLLM.ChatFunctionInvocation.FunctionResult
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
