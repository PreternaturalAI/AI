//
// Copyright (c) Vatsal Manot
//

import Anthropic
import LargeLanguageModels
import XCTest

public var ANTHROPIC_API_KEY: String {
    ""
}

public var client: Anthropic {
    Anthropic(apiKey: ANTHROPIC_API_KEY)
}
