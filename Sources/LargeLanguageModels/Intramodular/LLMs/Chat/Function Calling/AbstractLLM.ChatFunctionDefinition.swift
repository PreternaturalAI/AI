//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

extension AbstractLLM {
    public struct ChatFunctionDefinition: Codable, Hashable, Identifiable, Sendable {
        public typealias ID = _TypeAssociatedID<Self, AnyPersistentIdentifier>
        
        public let id: ID
        public let name: AbstractLLM.ChatFunction.Name
        public let context: String
        public let parameters: JSONSchema
        
        public init(
            id: AnyPersistentIdentifier? = nil,
            name: AbstractLLM.ChatFunction.Name,
            context: String,
            parameters: JSONSchema
        ) {
            self.id = id.map({ ID(rawValue: $0) }) ?? ID(rawValue: AnyPersistentIdentifier(rawValue: UUID()))
            self.name = name
            self.context = context
            self.parameters = parameters
        }
    }
}
