//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swallow

extension AbstractLLM {
    public struct ChatFunctionDefinition: Codable, Hashable, Identifiable, Sendable {
        public typealias ID = _TypeAssociatedID<Self, AnyPersistentIdentifier>
        
        public let id: ID
        public let name: String
        public let context: String
        public let parameters: JSONSchema
        
        public init(
            name: String,
            context: String,
            parameters: JSONSchema
        ) {
            self.id = ID(rawValue: AnyPersistentIdentifier(rawValue: UUID()))
            self.name = name
            self.context = context
            self.parameters = parameters
        }
    }
}
