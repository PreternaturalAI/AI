//
// Copyright (c) Vatsal Manot
//

import Mistral

public var MISTRAL_API_KEY: String {
    ""
}

public var client: Mistral.Client {
    Mistral.Client(apiKey: MISTRAL_API_KEY)
}
