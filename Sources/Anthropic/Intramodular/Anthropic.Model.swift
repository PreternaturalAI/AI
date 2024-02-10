//
// Copyright (c) Vatsal Manot
//

import CoreGML
import LargeLanguageModels
import Swallow

extension Anthropic {
    public enum Model: String, CaseIterable, Codable, Hashable, Sendable {
        case claude_v1 = "claude-v1"
        case claude_v2 = "claude-2"
        case claude_instant_v1 = "claude-instant-v1"
        
        case claude_v1_0 = "claude-v1.0"
        case claude_v1_2 = "claude-v1.2"
        case claude_v1_3 = "claude-v1.3"
        case claud_instant_v1_0 = "claude-instant-v1.0"
        case claud_instant_v1_2 = "claude-instant-v1.2"
        case claud_instant_1 = "claude-instant-1"
        
        public var name: String {
            switch self {
                case .claude_v1:
                    return "Claude 1"
                case .claude_v2:
                    return "Claude 2"
                case .claude_instant_v1:
                    return "Claude Instant 1"
                case .claude_v1_0:
                    return "Claude 1.0"
                case .claude_v1_2:
                    return "Claude 1.2"
                case .claude_v1_3:
                    return "Claude 1.3"
                case .claud_instant_v1_0:
                    return "Claude Instant 1.0"
                case .claud_instant_v1_2:
                    return "Claude Instant 1.2"
                case .claud_instant_1:
                    return "Claude Instant 1"
            }
        }
    }
}

extension Anthropic.Model: _GMLModelIdentifierRepresentable {
    public init(from model: _GMLModelIdentifier) throws {
        guard model.provider == .openAI else {
            throw _PlaceholderError()
        }
        
        self = try Self(rawValue: model.name).unwrap()
    }
    
    public func __conversion() -> _GMLModelIdentifier {
        _GMLModelIdentifier(
            provider: .anthropic,
            name: rawValue,
            revision: nil
        )
    }
}
