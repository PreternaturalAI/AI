//
// Copyright (c) Vatsal Manot
//

import VoyageAI

public var VOYAGEAI_API_KEY: String {
    ""
}

public var client: VoyageAI.Client {
    VoyageAI.Client(apiKey: VOYAGEAI_API_KEY)
}
