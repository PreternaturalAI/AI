//
// Copyright (c) Vatsal Manot
//

import Perplexity

public var PERPLEXITY_API_KEY: String {
    "API_KEY "
}

public var client: Perplexity.Client {
    Perplexity.Client(apiKey: PERPLEXITY_API_KEY)
}

