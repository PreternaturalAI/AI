//
//  module.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Anthropic
import LargeLanguageModels
import XCTest

public var GEMINI_API_KEY: String {
    ""
}

public var client: _Gemini.Client {
    _Gemini.Client(apiKey: GEMINI_API_KEY)
}
