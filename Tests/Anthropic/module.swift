//
// Copyright (c) Vatsal Manot
//

import Anthropic
import LargeLanguageModels
import XCTest

public var ANTHROPIC_API_KEY: String {
    ""
}

public var client: Anthropic.Client {
    Anthropic.Client(apiKey: ANTHROPIC_API_KEY)
}
