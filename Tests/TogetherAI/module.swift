//
// Copyright (c) Preternatural AI, Inc.
//

import TogetherAI

public var TOGETHERAI_API_KEY: String {
    ""
}

public var client: TogetherAI.Client {
    TogetherAI.Client(apiKey: TOGETHERAI_API_KEY)
}
