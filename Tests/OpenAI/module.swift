//
// Copyright (c) Vatsal Manot
//

import OpenAI

public var OPENAI_API_KEY: String {
    ""
}

public var client: OpenAI.APIClient {
    OpenAI.APIClient(apiKey: OPENAI_API_KEY)
}
