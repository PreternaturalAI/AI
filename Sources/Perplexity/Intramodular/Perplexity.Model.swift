//
// Copyright (c) Preternatural AI, Inc.
//

import CoreMI
import CorePersistence
import LargeLanguageModels
import Swallow

extension Perplexity {
    public enum Model: String, CaseIterable, Codable, Hashable, Named, Sendable {
        case llama3SonarSmall32kChat = "llama-3-sonar-small-32k-chat"
        case llama3SonarSmall32kOnline = "llama-3-sonar-small-32k-online"
        case llama3SonarLarge32kChat = "llama-3-sonar-large-32k-chat"
        case llama3SonarLarge32kOnline = "llama-3-sonar-large-32k-online"
        case llama38bInstruct = "llama-3-8b-instruct"
        case llama370bInstruct = "llama-3-70b-instruct"
        case mixtral8x7bInstruct = "mixtral-8x7b-instruct"
        
        case llamaSonarSmall128kOnline = "llama-3.1-sonar-small-128k-online"
        case llamaSonarLarge128kOnline = "llama-3.1-sonar-large-128k-online"
        case llamaSonarHuge128kOnline = "llama-3.1-sonar-huge-128k-online"
        
        public var name: String {
            switch self {
                case .llama3SonarSmall32kChat:
                    return "Llama 3 Sonar Small 32K (Chat)"
                case .llama3SonarSmall32kOnline:
                    return "Llama 3 Sonar Small 32K (Online)"
                case .llama3SonarLarge32kChat:
                    return "Llama 3 Sonar Large 32K (Chat)"
                case .llama3SonarLarge32kOnline:
                    return "Llama 3 Sonar Large 32K (Online)"
                case .llama38bInstruct:
                    return "Llama 3 8B Instruct"
                case .llama370bInstruct:
                    return "Llama 3 70B Instruct"
                case .mixtral8x7bInstruct:
                    return "Mixtral 8x7B Instruct"
                case .llamaSonarSmall128kOnline:
                    return "Llama 3.1 Sonar Small 128K Online"
                case .llamaSonarLarge128kOnline:
                    return "Llama 3.1 Sonar Large 128K Online"
                case .llamaSonarHuge128kOnline:
                    return "Llama 3.1 Sonar Huge 128K Online"
            }
        }
    }
}

// MARK: - Conformances

extension Perplexity.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension Perplexity.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._Perplexity, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: ._Perplexity,
            name: rawValue,
            revision: nil
        )
    }
}
