//
// Copyright (c) Vatsal Manot
//

import Groq

public var GROQ_API_KEY: String {
    ""
}

public var client: Groq.Client {
    Groq.Client(apiKey: GROQ_API_KEY)
}
