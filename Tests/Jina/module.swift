//
// Copyright (c) Vatsal Manot
//

import Jina

public var JINA_API_KEY: String {
    ""
}

public var client: Jina.Client {
    Jina.Client(apiKey: JINA_API_KEY)
}
