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
                "CoreGML",
                "LargeLanguageModels",
                "AI",
                "Anthropic",
                "ElevenLabs",
                "Mistral",
                "Ollama",
                "OpenAI",
                "Perplexity"
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
            name: "CoreGML",
            dependencies: [
                "CorePersistence",
                "Merge",
                "Swallow"
            ],
            path: "Sources/CoreGML"
        ),
        .target(
            name: "LargeLanguageModels",
            dependencies: [
                "CorePersistence",
                "CoreGML",
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
            name: "AI",
            dependencies: [
                "CoreGML",
                "LargeLanguageModels",
            ],
            path: "Sources/AI",
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
                "CoreGML",
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
                "CoreGML",
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
                "CoreGML",
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
                "CoreGML",
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
