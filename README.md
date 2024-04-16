> [!IMPORTANT]
> This package is presently in its alpha stage of development

[![Swift](https://github.com/PreternaturalAI/AI/actions/workflows/swift.yml/badge.svg)](https://github.com/PreternaturalAI/AI/actions/workflows/swift.yml)

#### Supported Platforms
<p align="left">
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Images/macos.svg">
  <source media="(prefers-color-scheme: light)" srcset="Images/macos-active.svg">
  <img alt="macos" src="Images/macos-active.svg" height="24">
</picture>&nbsp;
<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Images/ios.svg">
  <source media="(prefers-color-scheme: light)" srcset="Images/ios-active.svg">
  <img alt="macos" src="Images/ios-active.svg" height="24">
</picture>&nbsp;

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Images/ipados.svg">
  <source media="(prefers-color-scheme: light)" srcset="Images/ipados-active.svg">
  <img alt="macos" src="Images/ipados-active.svg" height="24">
</picture>&nbsp;

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Images/tvos.svg">
  <source media="(prefers-color-scheme: light)" srcset="Images/tvos-active.svg">
  <img alt="macos" src="Images/tvos-active.svg" height="24">
</picture>&nbsp;

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="Images/watchos.svg">
  <source media="(prefers-color-scheme: light)" srcset="Images/watchos-active.svg">
  <img alt="macos" src="Images/watchos-active.svg" height="24">
</picture>
</p>

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

### Import the framework

```diff
+ import AI
```

### Initialize a model

Initialize an instance of `LLMRequestHandling` with an API provider of your choice. Here's an example:

```swift
import AI
import OpenAI

let llm: any LLMRequestHandling = OpenAI.APIClient(apiKey: "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
```

You can now use `llm` as an interface to an LLM as provided by the underlying provider.

### Chat completions

In the snippet earlier, we initialized an instance of `LLMRequestHandling` with OpenAI as the underlying provider.

OpenAI offers a number of **chat models**, like GPT-3.5 and GPT-4.

A chat model is a language model that can be given a set of messages and asked to generate a response that follows in turn.

You can use the `LLMRequestHandling.complete(_:model:)` function to generate a chat completion for a specific model of your choice. For example:

```swift
/// ...

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

In this example we constructed an ordered array of chat messages, and used our `llm` instance to generate a completion using GPT-4.

# Roadmap
<img src="https://github.com/PreternaturalAI/AI/assets/8635253/72722dd4-428c-4b2f-9c49-69e1515862af" width="400">


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
