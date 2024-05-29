//
// Copyright (c) Vatsal Manot
//

import OpenAI

public var OPENAI_API_KEY: String {
    ""
}

public var client: OpenAI.Client {
    let client = OpenAI.Client(apiKey: OPENAI_API_KEY)
        
    return client
}
