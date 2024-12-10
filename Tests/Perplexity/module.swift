//
// Copyright (c) Vatsal Manot
//

import Perplexity

public var PERPLEXITY_API_KEY: String {
    "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"
}

public var client: Perplexity.Client {
    Perplexity.Client(apiKey: PERPLEXITY_API_KEY)
}

