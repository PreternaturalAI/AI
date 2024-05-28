//
//  File.swift
//  
//
//  Created by Natasha Murashev on 5/26/24.
//

import Groq

public var GROQ_API_KEY: String {
    ""
}

public var client: Groq {
    Groq(apiKey: GROQ_API_KEY)
}
