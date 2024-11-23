//
//  NeetsAI.Model.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import CoreMI
import CorePersistence
import Foundation
import Swift

extension NeetsAI {
    public enum Model: String, Codable, Sendable {
        case arDiff50k = "ar-diff-50k"
        case styleDiff500 = "style-diff-500"
        case vits = "vits"
        case mistralai = "mistralai/Mixtral-8X7B-Instruct-v0.1"
    }
}

// MARK: - Model Conformances

extension NeetsAI.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension NeetsAI.Model: ModelIdentifierRepresentable {
    public init(from identifier: ModelIdentifier) throws {
        guard identifier.provider == ._NeetsAI, identifier.revision == nil else {
            throw Never.Reason.illegal
        }
        
        guard let model = Self(rawValue: identifier.name) else {
            throw Never.Reason.unexpected
        }
        
        self = model
    }
    
    public func __conversion() throws -> ModelIdentifier {
        ModelIdentifier(
            provider: ._NeetsAI,
            name: rawValue,
            revision: nil
        )
    }
}
