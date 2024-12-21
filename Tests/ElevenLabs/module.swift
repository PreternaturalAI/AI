//
// Copyright (c) Preternatural AI, Inc.
//

import ElevenLabs

public var ELEVENLABS_API_KEY: String {
    ""
}

public var client: ElevenLabs.Client {
    let client = ElevenLabs.Client(apiKey: ELEVENLABS_API_KEY)
        
    return client
}
