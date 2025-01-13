//
//  _Gemini.CLient.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import CoreMI
import CorePersistence
import Diagnostics
import NetworkKit
import FoundationX
import Merge
import Swallow

extension _Gemini {
    @HadeanIdentifier("nagik-didah-dufak-nipav")
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public typealias API = _Gemini.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(configuration: API.Configuration) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(apiKey: String?) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension _Gemini.Client: CoreMI._ServiceClientProtocol {
    public func _globalFileSpace() -> any CoreMI._ServiceProvisionedFileSpace {
        _Gemini.Client.FileSpace(client: self)
    }
    
    public convenience init(
        account: (any CoreMI._ServiceAccountProtocol)?
    ) async throws {
        let account: any CoreMI._ServiceAccountProtocol = try account.unwrap()
        let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier = try account.serviceVendorIdentifier.unwrap()
        
        guard serviceVendorIdentifier == CoreMI._ServiceVendorIdentifier._OpenAI else {
            throw CoreMI._ServiceClientError.incompatibleVendor(serviceVendorIdentifier)
        }
        
        guard let credential = try account.credential as? CoreMI._ServiceCredentialTypes.APIKeyCredential else {
            throw CoreMI._ServiceClientError.invalidCredential(try account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
