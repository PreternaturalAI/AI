//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
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
    
    public struct ChatCompletionParameters: CompletionParameters {
        public let tokenLimit: TokenLimit?
        public let temperatureOrTopP: TemperatureOrTopP?
        public let stops: [String]?
        public let functions: IdentifierIndexingArrayOf<ChatFunctionDefinition>?
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit? = nil,
            temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
            stops: [String]? = nil,
            functions: [ChatFunctionDefinition]? = nil
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperatureOrTopP
            self.stops = stops
            self.functions = functions.map({ IdentifierIndexingArrayOf($0) })
        }
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit? = nil,
            temperatureOrTopP: AbstractLLM.TemperatureOrTopP? = nil,
            stops: [String]? = nil,
            tools: [ChatFunctionDefinition]? 
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperatureOrTopP
            self.stops = stops
            self.functions = tools.map({ IdentifierIndexingArrayOf($0) })
        }
        
        public init(
            tokenLimit: AbstractLLM.TokenLimit?,
            temperature: Double?,
            stops: [String]?,
            functions: [ChatFunctionDefinition]?
        ) {
            self.tokenLimit = tokenLimit
            self.temperatureOrTopP = temperature.map({ .temperature($0) })
            self.stops = stops
            self.functions = functions.map({ IdentifierIndexingArrayOf($0) })
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatCompletionParameters: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self.init(tokenLimit: nil, temperatureOrTopP: nil, stops: nil, functions: nil)
    }
}
