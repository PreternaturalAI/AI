> [!IMPORTANT]
> This package is presently in its alpha stage of development

[![Swift](https://github.com/PreternaturalAI/AI/actions/workflows/swift.yml/badge.svg)](https://github.com/PreternaturalAI/AI/actions/workflows/swift.yml)

# AI

The definitive, open-source Swift framework for interfacing with generative AI.

# Installation

### Swift Package Manager

1. Open your Swift project in Xcode.
2. Go to `File` -> `Add Package Dependency`.
3. In the search bar, enter [this URL](https://github.com/PreternaturalAI/AI.git).
4. Choose the version you'd like to install.
5. Click `Add Package`.

# Usage

```swift
import AI
```

Chat completions:

```swift
let llm: any LLMRequestHandling = OpenAI.APIClient(apiKey: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")

let messages: [AbstractLLM.ChatMessage] = [
    AbstractLLM.ChatMessage(
        role: .system,
        body: "You are an extremely intelligent assistant."
    ),
    AbstractLLM.ChatMessage(
        role: .user,
        body: "Sup?"
    )
]

let result = try await llm.complete(
    messages,
    model: OpenAI.Model.chat(.gpt_4)
)

print(result) // "Hello! How can I assist you today?"
```

# Roadmap

- [x] OpenAI
- [x] Anthropic
- [x] Mistral
- [x] Ollama
- [ ] Perplexity
- [ ] Groq

# Acknowledgements

- [similarity-search-kit](https://github.com/ZachNagengast/similarity-search-kit)
- [Tiktoken](https://github.com/aespinilla/Tiktoken)

# License

This package is licensed under the MIT License.
