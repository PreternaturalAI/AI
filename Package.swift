// swift-tools-version:5.10

import PackageDescription

let package = Package(
    name: "AI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "AI",
            targets: [
                "CoreMI",
                "LargeLanguageModels",
                "Anthropic",
                "ElevenLabs",
                "_Gemini",
                "Groq",
                "Mistral",
                "Ollama",
                "OpenAI",
                "Perplexity",
                "AI",
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
                "SwiftUIX",
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
            name: "_Gemini",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/_Gemini"
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
            path: "Sources/Mistral"
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
            path: "Sources/Groq"
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
            path: "Sources/Jina"
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
            path: "Sources/VoyageAI"
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
            path: "Sources/Cohere"
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
            path: "Sources/TogetherAI"
        ),
        .target(
            name: "AI",
            dependencies: [
                "CoreMI",
                "LargeLanguageModels",
                "Anthropic",
                "ElevenLabs",
                "Mistral",
                "_Gemini",
                "Groq",
                "Ollama",
                "OpenAI",
                "Perplexity",
                "Swallow",
                "Jina",
                "VoyageAI",
                "Cohere",
                "TogetherAI"
            ],
            path: "Sources/AI",
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
            name: "TogehterAITests",
            dependencies: [
                "AI",
                "Swallow"
            ],
            path: "Tests/TogetherAI",
            swiftSettings: [
                .enableExperimentalFeature("AccessLevelOnImport")
            ]
        )
    ]
)
