//
// Copyright (c) Vatsal Manot
//

import ElevenLabs

public var ELEVENLABS_API_KEY: String {
    "0dea648f8b5c9497b647902ae00e6903"
}

public var client: ElevenLabs.Client {
    let client = ElevenLabs.Client(apiKey: ELEVENLABS_API_KEY)
        
    return client
}
