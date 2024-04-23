//
// Copyright (c) Vatsal Manot
//

import OpenAI

public var OPENAI_API_KEY: String {
    "AuOrGGtZAmwYz9skIVCoT3BlbkFJKrZUDcDfQT2MCS6s4P7e"
}

public var client: OpenAI.APIClient {
    OpenAI.APIClient(apiKey: OPENAI_API_KEY)
}
