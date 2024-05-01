//
// Copyright (c) Vatsal Manot
//

import OpenAI

public var OPENAI_API_KEY: String {
    "sk-proj-S7Ut3eDrehdVOAzae6NmT3BlbkFJLop7OieQ030Rg1Ej2EFc"
}

public var client: OpenAI.APIClient {
    OpenAI.APIClient(apiKey: OPENAI_API_KEY)
}
