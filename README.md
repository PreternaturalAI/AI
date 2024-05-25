> [!IMPORTANT]
> This package is presently in its alpha stage of development

[![Swift](https://github.com/PreternaturalAI/AI/actions/workflows/swift.yml/badge.svg)](https://github.com/PreternaturalAI/AI/actions/workflows/swift.yml)


<div align="center">
<img src="https://github.com/PreternaturalAI/AI/assets/8635253/6ee85468-8fdf-4c32-92a3-44b8f2fe1eb5" width="400">

[Website](https://www.preternatural.ai) | [Documentation](https://preternatural.github.com)

---

</div>

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

[Installation](#installation)\
[Usage](#usage) 

* [Import the framework](#import-the-framework)
* [Initialize an AI Client](#initialize-an-ai-client)
* [Supported Models](#supported-models)
* [Completions](#completions)
  * [Basic Completions](#basic-completions)
  * [Vision: Image-to-Text](#vision-image-to-text)
* [DALLE-3 Image Generation](#dalle-3-image-generation)
* [Text Embeddings](#text-embeddings) 

[Roadmap](#roadmap) \
[Acknowledgements](#acknowledgements) \
[License](#license)

# Installation

## Swift Package Manager

1. Open your Swift project in Xcode.
2. Go to `File` -> `Add Package Dependency`.
3. In the search bar, enter [this URL](https://github.com/PreternaturalAI/AI.git).
4. Choose the version you'd like to install.
5. Click `Add Package`.

# Usage

## Import the framework

```diff
+ import AI
```

## Initialize an AI Client

Initialize an instance of `LLMRequestHandling` with an API provider of your choice. Here are some examples:

```swift
import AI

import OpenAI
import Anthropic
import Mistral

// OpenAI / GPT
let client: any LLMRequestHandling = OpenAI.APIClient(apiKey: "YOUR_KEY")
// Anthropic / Claude
let client: any LLMRequestHandling  = Anthropic(apiKey: "YOUR_KEY")
// Mistral
let client: any LLMRequestHandling = Mistral(apiKey: "YOUR_KEY")
```

You can now use `client` as an interface to an LLM as provided by the underlying provider.

## Supported Models
Each AI Client supports multiple models. For example:

```swift
// OpenAI Models
let gpt_4o_Model = OpenAI.Model.gpt_4o
let gpt_4_Model = OpenAI.Model.gpt_4
let gpt_3_5_Model = OpenAI.Model.gpt_3_5
let otherGPTModels = OpenAI.Model.chat(.gpt_OTHER_MODEL_OPTIONS)

// Anthropic Models
let caludeHaikuModel = Anthropic.Model.haiku
let claudeSonnetModel = Anthropic.Model.sonnet
let claudeOpusModel = Anthropic.Model.opus

// Mistral Models
let mistralTiny = Mistral.Model.mistral_tiny
let mistralSmall = Mistral.Model.mistral_small
let mistralMedium = Mistral.Model.mistral_medium
```

## Completions
### Basic Completions

Modern Large Language Models (LLMs) operate by receiving a series of inputs, often in the form of messages or prompts, and completing the inputs with the next probable output based on calculations performed by their complex neural network architectures that leverage the vast amounts of data on which it was trained.

You can use the `LLMRequestHandling.complete(_:model:)` function to generate a chat completion for a specific model of your choice. For example:

```swift
import AI
import OpenAI

let llm: any LLMRequestHandling = OpenAI.APIClient(apiKey: "YOUR_KEY")

let messages: [AbstractLLM.ChatMessage] = [
        // the system prompt is optional
        .system(PromptLiteral("You are an extremely intelligent assistant.")),
        .user(PromptLiteral("What is the meaning of life?"))
  ]

// Each of these is Optional
let parameters = AbstractLLM.ChatCompletionParameters(
    // .max or maximum amount of tokens is default
    tokenLimit: .fixed(200), 
    // controls the randomness of the result
    temperatureOrTopP: .temperature(1.2), 
    // stop sequences that indicate to the model when to stop generating further text
    stops: ["\nUser:", "\nAssistant:"],
    // check the function calling section below
    functions: nil)

let model = OpenAI.Model.gpt_4o

do {

    let result: String = try await client.complete(
        messages,
        parameters: parameters,
        model: model,
        as: .string)
    
    return result
} catch {
    print(error)
}
```

### Vision: Image-to-Text
Language models (LLMs) are rapidly evolving and expanding into multimodal capabilities. This shift signifies a major transformation in the field, as LLMs are no longer limited to understanding and generating text. With Vision, LLMs can take an image as an input, and provide information about the content of the image.

```swift
import AI
import OpenAI

let client: any LLMRequestHandling = OpenAI.APIClient(apiKey: "YOUR_KEY")

let systemPrompt = "You are a VisionExpertGPT. You will receive an image. Your job is to list all the items in the image and write a one-sentence poem about each item. Make sure your poems are creative, capturing the essence of each item in an evocative and imaginative way."

let userPrompt = "List the items in this image and write a short one-sentence poem about each item. Only reply with the items and poems. NOTHING MORE."

// Image or NSImage is supported
let imageLiteral = try PromptLiteral(image: imageInput) 

let model = OpenAI.Model.gpt_4o
  
let messages: [AbstractLLM.ChatMessage] = [
    .system(PromptLiteral(systemPrompt),
    .user {
        .concatenate(separator: nil) {
            PromptLiteral(userPrompt)
            imageLiteral
        }
    }]

let result = try await client.complete(
    messages,
    model: model
)

return result.message.content.description
```

## DALLE-3 Image Generation
With OpenAI's DALLE-3, text-to-image generation is as easy as just providing a prompt. This gives us, as Apple Developers, the opportunity to include very personalized images for all kinds of use-cases instead of using any generic stock images. 

For instance, consider we are building a personal journal app. With the DALLE-3 Image Generation API by OpenAI, we can generate a unique, beautiful image for each journal entry. 

```swift
import AI
import OpenAI

let client: any LLMRequestHandling = OpenAI.APIClient(apiKey: "YOUR_KEY")

// user's journal entry for today. 
// Note that the imagePrompt should be less than 4000 characters. 
let imagePrompt = "Today was an unforgettable day in Japan, filled with awe and wonder at every turn. We began our journey in the bustling streets of Tokyo, where the neon lights and towering skyscrapers left us mesmerized. The serene beauty of the Meiji Shrine provided a stark contrast, offering a peaceful retreat amidst the city's chaos. We indulged in delicious sushi at a local restaurant, the flavors so fresh and vibrant. Later, we took a train to Kyoto, where the sight of the historic temples and the tranquil Arashiyama Bamboo Grove left us breathless. The day ended with a soothing dip in an onsen, the hot springs melting away all our fatigue. Japan's blend of modernity and tradition, coupled with its unparalleled hospitality, made this trip a truly magical experience."

let images = try await openAIClient.createImage(
    prompt: imagePrompt,
    // either standard or hd (costs more)
    quality: OpenAI.Image.Quality.standard,
    // 1024x1024, 1792x1024, or 1024x1792 supported
    size: OpenAI.Image.Size.w1024h1024,
    // either vivid or natural
    style: OpenAI.Image.Style.vivid

if let imageURL = images.first?.url {
    return URL(string: imageURL)
}
```

## Text Embeddings
Text embedding models are translators for machines. They convert text, such as sentences or paragraphs, into sets of numbers, which the machine can easily use in complex calculations. The biggest use-case for Text Embeddings is improving Search in your application. 

Just simply provide any text and the model will return an embedding (an array of doubles) of that text back. 

```swift
import AI
import OpenAI

let client: any LLMRequestHandling = OpenAI.APIClient(apiKey: "YOUR_KEY")

// supported models (Only OpenAI Embeddings Models are supported)
let smallTextEmbeddingsModel = OpenAI.Model.embedding(.text_embedding_3_small)
let largeTextEmbeddingsModel = OpenAI.Model.embedding(.text_embedding_3_large)
let adaTextEmbeddingsModel = OpenAI.Model.embedding(.text_embedding_ada_002)

let textInput = "Hello, Text Embeddings!"

let textEmbeddingsModel = OpenAI.Model.embedding(.text_embedding_3_small)

let embeddings = try await LLMManager.client.textEmbeddings(
    for: [textInput],
    model: textEmbeddingsModel)
    
return embeddings.data.first?.embedding.description
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
