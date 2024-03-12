//
// Copyright (c) Vatsal Manot
//

import CoreMI
import LargeLanguageModels
import Swallow

extension Anthropic {
    public enum Model: String, CaseIterable, Codable, Hashable, Sendable {
        case claude_instant_v1 = "claude-instant-v1"
        case claude_v1 = "claude-v1"
        case claude_v2 = "claude-2"
        
        case claud_instant_v1_0 = "claude-instant-v1.0"
        case claud_instant_v1_2 = "claude-instant-v1.2"
        
        case claude_v1_0 = "claude-v1.0"
        case claude_v1_2 = "claude-v1.2"
        case claude_v1_3 = "claude-v1.3"
        
        case claude_3_sonnet_20240229 = "claude-3-sonnet-20240229"
        case claude_3_opus_20240229 = "claude-3-opus-20240229"
        
        public var isPointerToLatestVersion: Bool {
            switch self {
                case .claude_v1:
                    return true
                case .claude_v2:
                    return true
                case .claude_instant_v1:
                    return true
                default:
                    return false
            }
        }
        
        public var name: String {
            switch self {
                case .claude_v1:
                    return "Claude 1"
                case .claude_v2:
                    return "Claude 2"
                case .claude_instant_v1:
                    return "Claude Instant 1"
                    
                case .claud_instant_v1_0:
                    return "Claude Instant 1.0"
                case .claud_instant_v1_2:
                    return "Claude Instant 1.2"
                case .claude_v1_0:
                    return "Claude 1.0"
                case .claude_v1_2:
                    return "Claude 1.2"
                case .claude_v1_3:
                    return "Claude 1.3"
                case .claude_3_sonnet_20240229:
                    return "Claude 3 Sonnet"
                case .claude_3_opus_20240229:
                    return "Claude 3 Opus"
            }
        }
        
        public var contextSize: Int? {
            switch self {
                case .claude_3_sonnet_20240229:
                    return 200000
                case .claude_3_opus_20240229:
                    return 200000
                default:
                    return nil
            }
        }
    }
}

extension Anthropic.Model: _MLModelIdentifierRepresentable {
    public init(from model: _MLModelIdentifier) throws {
        guard model.provider == .anthropic else {
            throw _PlaceholderError()
        }
        
        self = try Self(rawValue: model.name).unwrap()
    }
    
    public func __conversion() -> _MLModelIdentifier {
        _MLModelIdentifier(
            provider: .anthropic,
            name: rawValue,
            revision: nil
        )
    }
}
