//
// Copyright (c) Preternatural AI, Inc.
//

import AI
@testable import _Gemini

public var GEMINI_API_KEY: String {
    // Add your API key here or load from environment
    ""
}

public var client: _Gemini.Client {
    _Gemini.Client(apiKey: GEMINI_API_KEY)
}
