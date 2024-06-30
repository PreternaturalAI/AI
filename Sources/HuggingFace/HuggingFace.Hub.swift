//
//  Hub.swift
//  
//
//  Created by Pedro Cuenca on 18/5/23.
//

import Foundation

extension HuggingFace {
    public struct Hub {}
}

public extension HuggingFace.Hub {
    enum HubClientError: Error {
        case parse
        case authorizationRequired
        case unexpectedError
        case httpStatusCode(Int)
    }
    
    enum RepoType: String {
        case models
        case datasets
        case spaces
    }
    
    struct Repo {
        let id: String
        let type: RepoType
        
        public init(id: String, type: RepoType = .models) {
            self.id = id
            self.type = type
        }
    }
}

// MARK: - Configuration files with dynamic lookup

extension HuggingFace {
    @dynamicMemberLookup
    public struct Config {
        public private(set) var dictionary: [String: Any]
        
        public init(_ dictionary: [String: Any]) {
            self.dictionary = dictionary
        }
        
        func camelCase(_ string: String) -> String {
            return string
                .split(separator: "_")
                .enumerated()
                .map { $0.offset == 0 ? $0.element.lowercased() : $0.element.capitalized }
                .joined()
        }
        
        func uncamelCase(_ string: String) -> String {
            let scalars = string.unicodeScalars
            var result = ""
            
            var previousCharacterIsLowercase = false
            for scalar in scalars {
                if CharacterSet.uppercaseLetters.contains(scalar) {
                    if previousCharacterIsLowercase {
                        result += "_"
                    }
                    let lowercaseChar = Character(scalar).lowercased()
                    result += lowercaseChar
                    previousCharacterIsLowercase = false
                } else {
                    result += String(scalar)
                    previousCharacterIsLowercase = true
                }
            }
            
            return result
        }
        
        
        public subscript(dynamicMember member: String) -> Config? {
            let key = dictionary[member] != nil ? member : uncamelCase(member)
            if let value = dictionary[key] as? [String: Any] {
                return Config(value)
            } else if let value = dictionary[key] {
                return Config(["value": value])
            }
            return nil
        }
        
        public var value: Any? {
            return dictionary["value"]
        }
        
        public var intValue: Int? { value as? Int }
        public var boolValue: Bool? { value as? Bool }
        public var stringValue: String? { value as? String }
        
        // Instead of doing this we could provide custom classes and decode to them
        public var arrayValue: [Config]? {
            guard let list = value as? [Any] else { return nil }
            return list.map { Config($0 as! [String : Any]) }
        }
        
        /// Tuple of token identifier and string value
        public var tokenValue: (UInt, String)? { value as? (UInt, String) }
    }
}

extension HuggingFace {
    public class LanguageModelConfigurationFromHub {
        struct Configurations {
            var modelConfig: HuggingFace.Config
            var tokenizerConfig: HuggingFace.Config?
            var tokenizerData: HuggingFace.Config
        }
        
        private var configPromise: Task<Configurations, Error>? = nil
        
        public init(
            modelName: String,
            client: HuggingFace.Hub.Client = .shared
        ) {
            self.configPromise = Task.init {
                return try await self.loadConfig(modelName: modelName, client: client)
            }
        }
        
        public init(
            modelFolder: URL,
            client: HuggingFace.Hub.Client = .shared
        ) {
            self.configPromise = Task {
                return try await self.loadConfig(modelFolder: modelFolder, client: client)
            }
        }
        
        public var modelConfig: HuggingFace.Config {
            get async throws {
                try await configPromise!.value.modelConfig
            }
        }
        
        public var tokenizerConfig: HuggingFace.Config? {
            get async throws {
                if let hubConfig = try await configPromise!.value.tokenizerConfig {
                    // Try to guess the class if it's not present and the modelType is
                    if let _ = hubConfig.tokenizerClass?.stringValue { return hubConfig }
                    guard let modelType = try await modelType else { return hubConfig }
                    
                    // If the config exists but doesn't contain a tokenizerClass, use a fallback config if we have it
                    if let fallbackConfig = Self.fallbackTokenizerConfig(for: modelType) {
                        let configuration = fallbackConfig.dictionary.merging(hubConfig.dictionary, uniquingKeysWith: { current, _ in current })
                        return HuggingFace.Config(configuration)
                    }
                    
                    // Guess by capitalizing
                    var configuration = hubConfig.dictionary
                    configuration["tokenizer_class"] = "\(modelType.capitalized)Tokenizer"
                    return HuggingFace.Config(configuration)
                }
                
                // Fallback tokenizer config, if available
                guard let modelType = try await modelType else { return nil }
                return Self.fallbackTokenizerConfig(for: modelType)
            }
        }
        
        public var tokenizerData: HuggingFace.Config {
            get async throws {
                try await configPromise!.value.tokenizerData
            }
        }
        
        public var modelType: String? {
            get async throws {
                try await modelConfig.modelType?.stringValue
            }
        }
        
        func loadConfig(
            modelName: String,
            client: HuggingFace.Hub.Client = .shared
        ) async throws -> Configurations {
            let filesToDownload = ["config.json", "tokenizer_config.json", "tokenizer.json"]
            let repo = HuggingFace.Hub.Repo(id: modelName)
            let downloadedModelFolder = try await client.snapshot(from: repo, matching: filesToDownload)
            
            return try await loadConfig(modelFolder: downloadedModelFolder, client: client)
        }
        
        func loadConfig(
            modelFolder: URL,
            client: HuggingFace.Hub.Client = .shared
        ) async throws -> Configurations {
            // Note tokenizerConfig may be nil (does not exist in all models)
            let modelConfig = try client.configuration(fileURL: modelFolder.appending(path: "config.json"))
            let tokenizerConfig = try? client.configuration(fileURL: modelFolder.appending(path: "tokenizer_config.json"))
            let tokenizerVocab = try client.configuration(fileURL: modelFolder.appending(path: "tokenizer.json"))
            
            let configs = Configurations(
                modelConfig: modelConfig,
                tokenizerConfig: tokenizerConfig,
                tokenizerData: tokenizerVocab
            )
            return configs
        }
        
        static func fallbackTokenizerConfig(for modelType: String) -> HuggingFace.Config? {
            let fileManager = FileManager.default
            let currentDirectoryURL = URL(fileURLWithPath: fileManager.currentDirectoryPath)
            let fallbackConfigsURL = currentDirectoryURL.appendingPathComponent("Sources/HuggingFace/FallbackConfigs")
            let tokenConfigURL = fallbackConfigsURL.appendingPathComponent("\(modelType)_tokenizer_config.json")
            
            guard fileManager.fileExists(atPath: tokenConfigURL.path) else { return nil }
            
            do {
                let data = try Data(contentsOf: tokenConfigURL)
                let parsed = try JSONSerialization.jsonObject(with: data, options: [])
                guard let dictionary = parsed as? [String: Any] else { return nil }
                return HuggingFace.Config(dictionary)
            } catch {
                return nil
            }
        }
    }
}
