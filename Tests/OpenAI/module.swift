//
// Copyright (c) Vatsal Manot
//

import OpenAI

public var OPENAI_API_KEY: String {
    "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"
}

public var client: OpenAI.Client {
    let client = OpenAI.Client(apiKey: OPENAI_API_KEY)
        
    return client
}
