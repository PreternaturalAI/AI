//
// Copyright (c) Vatsal Manot
//

import TogetherAI

public var TOGETHERAI_API_KEY: String {
    "YOUR_API_KEY"
}

public var client: TogetherAI.Client {
    TogetherAI.Client(apiKey: TOGETHERAI_API_KEY)
}
