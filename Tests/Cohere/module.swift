//
// Copyright (c) Vatsal Manot
//

import Cohere

public var COHERE_API_KEY: String {
    ""
}

public var client: Cohere.Client {
    Cohere.Client(apiKey: COHERE_API_KEY)
}
