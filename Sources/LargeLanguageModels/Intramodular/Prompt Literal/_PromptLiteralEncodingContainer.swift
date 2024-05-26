//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

/// A type capable of encoding a `PromptLiteral` into itself.
///
/// This is a useful interface for 3rd party models to adopt to support conversion _from_ `PromptLiteral`.
///
/// This is a key protocol for performing a `PromptLiteral` -> `SomeModelProvider.ChatMessageType` conversion.
public protocol _PromptLiteralEncodingContainer {
    mutating func encode(
        _ degenerate: PromptLiteral._Degenerate.Component
    ) throws
}

// MARK: - Supplementary

extension PromptLiteral {
    /// Encode this literal into an encoding container.
    public func _encode<Container: _PromptLiteralEncodingContainer>(
        to container: inout Container
    ) throws {
        let degenerate = try _degenerate()
        
        for component in degenerate.components {
            try container.encode(component)
        }
    }
}
