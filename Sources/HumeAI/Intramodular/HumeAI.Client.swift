//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import LargeLanguageModels
import Merge
import NetworkKit
import Swallow

extension HumeAI {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public static var persistentTypeRepresentation: some IdentityRepresentation {
            CoreMI._ServiceVendorIdentifier._HumeAI
        }
        
        public typealias API = HumeAI.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(
            configuration: API.Configuration
        ) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(
            apiKey: String
        ) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension HumeAI.Client {
    // Text to Speech
    public func getAllAvailableVoices() async throws -> [HumeAI.Voice] {
        let response = try await run(\.listCustomVoices)
        
        return response.customVoicesPage
    }
}

// MARK: - Conformances

extension HumeAI.Client: CoreMI._ServiceClientProtocol {
    public convenience init(
        account: (any CoreMI._ServiceAccountProtocol)?
    ) async throws {
        let account: any CoreMI._ServiceAccountProtocol = try account.unwrap()
        let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier = try account.serviceVendorIdentifier.unwrap()
        
        guard serviceVendorIdentifier == CoreMI._ServiceVendorIdentifier._HumeAI else {
            throw CoreMI._ServiceClientError.incompatibleVendor(serviceVendorIdentifier)
        }
        
        guard let credential = try account.credential as? CoreMI._ServiceCredentialTypes.APIKeyCredential else {
            throw CoreMI._ServiceClientError.invalidCredential(try account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
