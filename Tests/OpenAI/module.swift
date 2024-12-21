//
// Copyright (c) Preternatural AI, Inc.
//

import OpenAI

public var client: OpenAI.Client {
    let client = OpenAI.Client(apiKey: nil)
        
    return client
}
