//
// Copyright (c) Vatsal Manot
//

import CoreGML
import CorePersistence

extension OpenAI.APIClient: _GMLModelService {
    public convenience init(
        account: (any _GMLModelServiceAccount)?
    ) async throws {
        let account = try account.unwrap()
        
        guard account.serviceIdentifier == _GMLModelServiceTypeIdentifier._OpenAI else {
            throw _GMLModelServiceError.incompatibleServiceType(account.serviceIdentifier)
        }
        
        guard let credential = account.credential as? _GMLModelServiceAPIKeyCredential else {
            throw _GMLModelServiceError.invalidCredential(account.credential)
        }
        
        self.init(apiKey: credential.apiKey)
    }
}
