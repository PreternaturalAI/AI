// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "AI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .visionOS(.v1),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "AI",
            targets: [
                "CoreMI",
                "LargeLanguageModels",
                "Anthropic",
                "Cohere",
                "ElevenLabs",
                "Groq",
                "HuggingFace",
                "Jina",
                "Mistral",
                "Ollama",
                "OpenAI",
                "AI",
            ]
        ),
        .library(
            name: "_Gemini",
            targets: [
                "_Gemini"
            ]
        ),
        .library(
            name: "Anthropic",
            targets: [
                "Anthropic"
            ]
        ),
        .library(
            name: "HumeAI",
            targets: [
                "HumeAI"
            ]
        ),
        .library(
            name: "NeetsAI",
            targets: [
                "NeetsAI"
            ]
        ),
        .library(
            name: "OpenAI",
            targets: [
                "OpenAI"
            ]
        ),
        .library(
            name: "Perplexity",
            targets: [
                "Perplexity"
            ]
        ),
        .library(
            name: "PlayHT",
            targets: [
                "PlayHT"
            ]
        ),
        .library(
            name: "Rime",
            targets: [
                "Rime"
            ]
        ),
        .library(
            name: "TogetherAI",
            targets: [
                "TogetherAI"
            ]
        ),
        .library(
            name: "VoyageAI",
            targets: [
                "VoyageAI"
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/vmanot/CorePersistence.git", branch: "main"),
        .package(url: "https://github.com/vmanot/Merge.git", branch: "master"),
        .package(url: "https://github.com/vmanot/NetworkKit.git", branch: "master"),
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master"),
        .package(url: "https://github.com/SwiftUIX/SwiftUIX.git", branch: "master")
    ],
    targets: [
        .target(
            name: "CoreMI",
            dependencies: [
                "CorePersistence",
                "Merge",
                "Swallow"
            ],
            path: "Sources/CoreMI"
        ),
        .target(
            name: "LargeLanguageModels",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "Merge",
                "NetworkKit",
                "Swallow",
                "SwiftUIX"
            ],
            path: "Sources/LargeLanguageModels",
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Anthropic",
            dependencies: [
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Anthropic",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "ElevenLabs",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/ElevenLabs",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "PlayHT",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/PlayHT",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Rime",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Rime",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "_Gemini",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/_Gemini",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Mistral",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Mistral",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Groq",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Groq",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Ollama",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Ollama",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "OpenAI",
            dependencies: [
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/OpenAI",
            resources: [],
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Perplexity",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "OpenAI",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Perplexity",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Jina",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Jina",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "VoyageAI",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/VoyageAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "Cohere",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Cohere",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "TogetherAI",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/TogetherAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "HumeAI",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/HumeAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "NeetsAI",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/NeetsAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "HuggingFace",
            dependencies: [
                "CoreMI",
                "Swallow"
            ],
            path: "Sources/HuggingFace",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .target(
            name: "AI",
            dependencies: [
                "CoreMI",
                "LargeLanguageModels",
                "Anthropic",
                "Cohere",
                "ElevenLabs",
                "Groq",
                "HuggingFace",
                "Jina",
                "Mistral",
                "Ollama",
                "OpenAI",
                "Swallow",
            ],
            path: "Sources/AI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "_GeminiTests",
            dependencies: [
                "AI",
                "Swallow",
                "_Gemini"
            ],
            path: "Tests/_Gemini",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "LargeLanguageModelsTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/LargeLanguageModels",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "AnthropicTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/Anthropic",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "MistralTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/Mistral",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "OpenAITests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/OpenAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "GroqTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/Groq",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "PerplexityTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/Perplexity",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "ElevenLabsTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/ElevenLabs",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "PlayHTTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/PlayHT",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "JinaTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/Jina",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "VoyageAITests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/VoyageAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "CohereTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/Cohere",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "HuggingFaceTests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/HuggingFace",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "NeetsAITests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/NeetsAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        ),
        .testTarget(
            name: "HumeAITests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/HumeAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        )
    ]
)

