//
// Copyright (c) Preternatural AI, Inc.
//

import NeetsAI

public var NEETSAI_API_KEY: String {
    ""
}

public var client: NeetsAI.Client {
    let client = NeetsAI.Client(
        apiKey: NEETSAI_API_KEY
    )
        
    return client
}

