//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import SwiftDI

extension Anthropic {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, PersistentlyRepresentableType, _StaticNamespaceType {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            _MIServiceTypeIdentifier._Anthropic
        }
        
        public let interface: API
        public let session: HTTPSession
        
        public init(interface: API, session: HTTPSession) {
            self.interface = interface
            self.session = session
            
            session.disableTimeouts()
        }
        
        public convenience init(apiKey: String?) {
            self.init(
                interface: API(configuration: .init(apiKey: apiKey)),
                session: .shared
            )
        }
    }
}

extension Anthropic.Client: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: Dependencies {
        var result = Dependencies()
        
        result[\.llm] = self
        
        return result
    }
}
