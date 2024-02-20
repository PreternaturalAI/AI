// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(
            name: "AI",
            targets: [
                "CoreMI",
                "LargeLanguageModels",
                "Anthropic",
                "ElevenLabs",
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
        .package(url: "https://github.com/vmanot/Swallow.git", branch: "master")
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
                "Swallow"
            ],
            path: "Sources/LargeLanguageModels",
            resources: [
                .process("Resources")
            ],
            swiftSettings: []
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
            swiftSettings: []
        ),
        .target(
            name: "ElevenLabs",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/ElevenLabs",
            swiftSettings: []
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
            name: "Ollama",
            dependencies: [
                "CorePersistence",
                "CoreMI",
                "LargeLanguageModels",
                "Merge",
                "NetworkKit",
                "Swallow"
            ],
            path: "Sources/Ollama"
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
            path: "Sources/Perplexity"
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
            resources: [
                .process("Resources")
            ],
            swiftSettings: []
        ),
        .target(
            name: "AI",
            dependencies: [
                "CoreMI",
                "LargeLanguageModels",
                "OpenAI"
            ],
            path: "Sources/AI",
            swiftSettings: []
        ),
        .testTarget(
            name: "LargeLanguageModelsTests",
            dependencies: [
                "LargeLanguageModels"
            ],
            path: "Tests/LargeLanguageModels"
        ),
        .testTarget(
            name: "AnthropicTests",
            dependencies: [
                "LargeLanguageModels"
            ],
            path: "Tests/Anthropic"
        ),
        .testTarget(
            name: "OpenAITests",
            dependencies: [
                "LargeLanguageModels",
                "OpenAI"
            ],
            path: "Tests/OpenAI"
        )
    ]
)
