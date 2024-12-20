//
//  module.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import AI
@testable import _Gemini

public var GEMINI_API_KEY: String {
    // Add your API key here or load from environment
    "AIzaSyBqk770M84lO0_LEYeXjdlpOBRyooVSUL4"
}

public var client: _Gemini.Client {
    _Gemini.Client(apiKey: GEMINI_API_KEY)
}
