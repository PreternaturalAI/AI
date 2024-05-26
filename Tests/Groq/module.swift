//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/26/24.
//

import OpenAI

public var GROQ_API_KEY: String {
    "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"
}

public var client: Groq {
    Groq(apiKey: GROQ_API_KEY)
}
