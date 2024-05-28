//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/26/24.
//

import Groq

public var GROQ_API_KEY: String {
    "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"
}

public var client: Groq.Client {
    Groq.Client(apiKey: GROQ_API_KEY)
}
