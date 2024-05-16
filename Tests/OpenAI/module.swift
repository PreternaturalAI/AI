//
// Copyright (c) Vatsal Manot
//

import OpenAI

public var OPENAI_API_KEY: String {
    "sk-proj-TDUbAbprSQy5E8N9D4ZnT3BlbkFJuszC5SfGKr9qNjOoKqKW"
}

public var client: OpenAI.APIClient {
    OpenAI.APIClient(apiKey: OPENAI_API_KEY)
}
