//
// Copyright (c) Vatsal Manot
//

import CoreMI
import NetworkKit
import Swallow

extension Anthropic.Client: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account: any _MIServiceAccount = try account.unwrap()
        let serviceIdentifier: _MIServiceTypeIdentifier = account.serviceIdentifier

        guard serviceIdentifier == _MIServiceTypeIdentifier._Anthropic else {
            throw _MIServiceError.serviceTypeIncompatible(serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
