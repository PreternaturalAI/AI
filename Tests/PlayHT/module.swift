//
// Copyright (c) Vatsal Manot
//

import ElevenLabs

public var PLAYHT_API_KEY: String {
    "0dea648f8b5c9497b647902ae00e6903"
}

public var client: PlayHT.Client {
    let client = PlayHT.Client(apiKey: PLAYHT_API_KEY)
        
    return client
}
