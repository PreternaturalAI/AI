
import CorePersistence

extension xAI {
    public struct ChatFunctionDefinition: Codable, Hashable, Sendable {
        public let name: String
        public let description: String
        public let parameters: JSONSchema
        
        public init(name: String, description: String, parameters: JSONSchema) {
            self.name = name
            self.description = description
            self.parameters = parameters
        }
    }
}

