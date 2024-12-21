//
// Copyright (c) Preternatural AI, Inc.
//

import PlayHT

public var PLAYHT_API_KEY: String {
    ""
}

public var PLAYHT_USER_ID: String {
    ""
}

public var client: PlayHT.Client {
    let client = PlayHT.Client(
        apiKey: PLAYHT_API_KEY,
        userID: PLAYHT_USER_ID
    )
        
    return client
}
