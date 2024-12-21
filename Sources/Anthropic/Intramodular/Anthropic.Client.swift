//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import SwiftDI

extension Anthropic {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, PersistentlyRepresentableType, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            CoreMI._ServiceVendorIdentifier._Anthropic
        }
        
        public let interface: API
        public let session: HTTPSession
        
        public init(
            interface: API,
            session: HTTPSession
        ) {
            self.interface = interface
            self.session = session
            
            session.disableTimeouts()
        }
        
        public convenience init(
            apiKey: String?
        ) {
            self.init(
                interface: API(configuration: Anthropic.API.Configuration(apiKey: apiKey)),
                session: .shared
            )
        }
    }
}

extension Anthropic.Client: CustomStringConvertible {
    public var description: String {
        let apiKey: String = self.interface.configuration.apiKey == nil ? "<nil>" : "<some>"
        
        return "Anthropic.Client(apiKey: \(apiKey))"
    }
}

extension Anthropic.Client: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: TaskDependencies {
        var result = TaskDependencies()
        
        result[\.llm] = self
        
        return result
    }
}
