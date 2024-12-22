//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

extension CoreMI {
    public enum _ServiceCredentialTypes {

    }
}

extension CoreMI {
    public enum _ServiceCredentialTypeIdentifier: Codable, Hashable, RawRepresentable, Sendable {
        case apiKey
        case custom(HadeanIdentifier)
        
        public var rawValue: String {
            switch self {
                case .apiKey:
                    return "apiKey"
                case .custom(let id):
                    return id.description
            }
        }
        
        public init?(rawValue: String) {
            switch rawValue {
                case CoreMI._ServiceCredentialTypeIdentifier.apiKey.rawValue:
                    self = .apiKey
                default:
                    if let identifier = HadeanIdentifier(rawValue) {
                        self = .custom(identifier)
                    } else {
                        return nil
                    }
            }
        }
                
        public static func custom<T: HadeanIdentifiable>(_ type: T.Type) -> Self {
            return .custom(type.hadeanIdentifier)
        }
        
        public func encode(to encoder: any Encoder) throws {
            try rawValue.encode(to: encoder)
        }
        
        public init(from decoder: any Decoder) throws {
            self = try Self(rawValue: String(from: decoder)).unwrap()
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "CoreMI._ServiceCredentialTypeIdentifier")
public typealias _MIServiceCredentialType = CoreMI._ServiceCredentialTypeIdentifier
