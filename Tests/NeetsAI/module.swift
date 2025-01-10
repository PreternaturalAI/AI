//
//  module.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import NeetsAI

public var NEETSAI_API_KEY: String {
    ""
}

public var client: NeetsAI.Client {
    let client = NeetsAI.Client(
        apiKey: NEETSAI_API_KEY
    )
        
    return client
}

