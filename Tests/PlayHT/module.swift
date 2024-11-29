//
// Copyright (c) Vatsal Manot
//

import PlayHT

public var PLAYHT_API_KEY: String {
    "fcfc923b8bd44fc383c9d23e409d52b1"
}

public var PLAYHT_USER_ID: String {
    "gze0b6x9kbXPVPOINZTAB09TsZ63"
}

public var client: PlayHT.Client {
    let client = PlayHT.Client(
        apiKey: PLAYHT_API_KEY,
        userID: PLAYHT_USER_ID
    )
        
    return client
}
