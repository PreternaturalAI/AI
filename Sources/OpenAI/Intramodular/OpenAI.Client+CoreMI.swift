//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence

extension OpenAI.Client: _MIService {
    public convenience init(
        account: (any _MIServiceAccount)?
    ) async throws {
        let account = try account.unwrap()
        
        guard account.serviceIdentifier == _MIServiceTypeIdentifier._OpenAI else {
            throw _MIServiceError.serviceTypeIncompatible(account.serviceIdentifier)
        }
        
        guard let credential = account.credential as? _MIServiceAPIKeyCredential else {
            throw _MIServiceError.invalidCredentials(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
