//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Foundation
import Swallow

/// A general purpose type to identify distinct machine-learning models.
///
/// It's intended for use with both local and API-only models.
@HadeanIdentifier("ludab-gulor-porin-zuvok")
@RuntimeDiscoverable
public struct ModelIdentifier: Hashable, Sendable {
    public let provider: ModelIdentifier.Provider
    public let name: String
    public let revision: String?
    
    public init(
        provider: ModelIdentifier.Provider,
        name: String,
        revision: String?
    ) {
        self.provider = provider
        self.name = name
        self.revision = revision
    }
    
    public init?(_ description: String) {
        self.init(description: description)
    }
}
// MARK: - Conformances

extension ModelIdentifier: Codable {
    public enum CodingKeys {
        case provider
        case name
        case revision
    }
    
    private struct _WithRevisionRepresentaton: Codable, Hashable {
        let provider: ModelIdentifier.Provider
        let name: String
        let revision: String
    }
    
    public init(from decoder: Decoder) throws {
        let containerKind = try decoder._determineContainerKind()
        
        do {
            switch containerKind {
                case .singleValue:
                    let container = try decoder.singleValueContainer()
                    
                    self = try Self(description: container.decode(String.self)).unwrap()
                case .unkeyed:
                    throw Never.Reason.illegal
                case .keyed:
                    let representation = try _WithRevisionRepresentaton(from: decoder)
                    
                    self.init(
                        provider: representation.provider,
                        name: representation.name,
                        revision: representation.revision
                    )
            }
        } catch {
            throw error
        }
    }
    
    public func encode(
        to encoder: Encoder
    ) throws {
        var container = encoder.singleValueContainer()
        
        if let revision {
            try container.encode(
                _WithRevisionRepresentaton(
                    provider: provider,
                    name: name,
                    revision: revision
                )
            )
        } else {
            try container.encode(description)
        }
    }
}

extension ModelIdentifier: CustomStringConvertible {
    public var description: String {
        provider.rawValue + "/" + name
    }
}

extension ModelIdentifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = Self(description: value)!
    }
}

extension ModelIdentifier: LosslessStringConvertible {
    public init?(description: String) {
        let components = description.components(separatedBy: "/")
        
        guard !components.isEmpty else {
            assertionFailure()
            
            return nil
        }
        
        guard components.count == 2 else {
            if components.count == 1 {
                let component = components.first!
                
                guard let provider = Self._guessPrimaryProvider(forRawIdentifier: component) else {
                    return nil
                }
                
                self.init(
                    provider: provider,
                    name: component,
                    revision: nil
                )
                
                return
            } else {
                return nil
            }
        }
        
        self.init(
            provider: .init(rawValue: components.first!),
            name: components.last!,
            revision: nil
        )
    }
}

extension ModelIdentifier: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        self = identifier
    }
    
    public func __conversion() throws -> ModelIdentifier {
        self
    }
}
