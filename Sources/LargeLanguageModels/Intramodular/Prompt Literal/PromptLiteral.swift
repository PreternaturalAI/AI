//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Foundation
import Swallow

/// The raw body of a text or a chat prompt.
///
/// Note:
/// - This can include function calls.
public struct PromptLiteral: ExpressibleByStringInterpolation, Hashable, Sendable {
    public var stringInterpolation: StringInterpolation
    
    public static var empty: PromptLiteral {
        .init(stringInterpolation: .init(components: []))
    }
    
    public var isEmpty: Bool {
        get throws {
            if stringInterpolation.components.isEmpty {
                return true
            }
            
            let isEmpty = try stringInterpolation._isEmpty
            
            return isEmpty
        }
    }
    
    public init(stringInterpolation: StringInterpolation) {
        self.stringInterpolation = stringInterpolation
    }
}

// MARK: - Initializers

extension PromptLiteral {
    public init(_ string: String, role: PromptMatterRole? = nil) {
        guard !string.isEmpty else {
            self = .empty
            
            return
        }
        
        self.init(stringInterpolation: .init(payload: .stringLiteral(string), role: role))
    }
    
    public init(
        functionCall call: AbstractLLM.ChatPrompt.FunctionCall,
        role: PromptMatterRole?
    ) throws {
        try _tryAssert(role == .chat(.assistant))
        
        self.init(stringInterpolation: .init(payload: .other(.functionCall(call)), role: role))
    }
    
    public init(
        functionCall call: AbstractLLM.ChatPrompt.FunctionCall
    ) throws {
        try self.init(functionCall: call, role: .chat(.assistant))
    }
    
    public init(
        functionInvocation invocation: AbstractLLM.ChatPrompt.RawFunctionInvocation,
        role: PromptMatterRole?
    ) throws {
        try _tryAssert(role == .chat(.other(.function)))
        
        self.init(stringInterpolation: .init(payload: .other(.functionInvocation(invocation)), role: role))
    }
    
    public init(_lazy value: any PromptLiteralConvertible) {
        if let value = value as? PromptLiteral {
            self = value
        } else {
            if let value = value as? any _opaque_DynamicPromptVariable {
                self.init(stringInterpolation: .init(payload: .dynamicVariable(value)))
            } else {
                self.init(stringInterpolation: .init(payload: .promptLiteralConvertible(value)))
            }
        }
    }
    
    public static func _lazy(_ value: () -> any PromptLiteralConvertible) -> Self {
        self.init(_lazy: value())
    }
    
    public init(_ variable: any _opaque_DynamicPromptVariable) {
        self.init(stringInterpolation: .init(payload: .dynamicVariable(variable)))
    }
}

// MARK: - Conformances

extension PromptLiteral: ExpressibleByStringLiteral {
    public init(stringLiteral: String) {
        self.init(stringInterpolation: .init(literalCapacity: 1, interpolationCount: 0))
        
        stringInterpolation.components = [
            StringInterpolation.Component(
                payload: .stringLiteral(stringLiteral),
                context: PromptLiteralContext()
            )
        ]
    }
}

extension PromptLiteral: Codable {
    public init(
        from decoder: Decoder
    ) throws {
        self.init(
            stringInterpolation: StringInterpolation(components: try Array<StringInterpolation.Component>(from: decoder))
        )
    }
    
    public func encode(
        to encoder: Encoder
    ) throws {
        try stringInterpolation.components.encode(to: encoder)
    }
}

extension PromptLiteral: CustomDebugStringConvertible, CustomStringConvertible {
    public var debugDescription: String {
        return stringInterpolation.components
            .map({
                $0.debugDescription
            })
            .joined()
            .trimmingWhitespace()
    }
    
    public var description: String {
        debugDescription
    }
}

// MARK: - Constructors

extension PromptLiteral {
    private var _skipSeparatorInConcatenation: Bool {
        guard stringInterpolation.components.count == 1 else {
            return false
        }
        
        switch stringInterpolation.components.first!.payload {
            case .stringLiteral:
                return false
            case .image:
                return true
            case .localizedStringResource:
                return false
            case .promptLiteralConvertible:
                return false
            case .dynamicVariable:
                return true
            case .other(let other):
                switch other {
                    case .functionCall:
                        return true
                    case .functionInvocation:
                        return true
                }
        }
    }
    
    public static func concatenate(
        separator: String?,
        prefix: String? = nil,
        @_SpecializedArrayBuilder<any PromptLiteralConvertible> _ literals: () throws -> [any PromptLiteralConvertible]
    ) rethrows -> Self {
        var result = PromptLiteral(stringInterpolation: .init())
        
        let literals = try literals()
            .map { literal -> PromptLiteral in
                if let prefix = prefix {
                    return PromptLiteral(stringLiteral: prefix) + PromptLiteral(_lazy: literal)
                } else {
                    return PromptLiteral(_lazy: literal)
                }
            }
            .filter({ (try? !$0.isEmpty) ?? true })
        
        if let separator {
            result.stringInterpolation.appendInterpolation(
                PromptLiteral(
                    stringInterpolation: PromptLiteral.StringInterpolation(
                        components: literals
                            .interspersed(
                                with: PromptLiteral(stringLiteral: separator),
                                where: { !$0._skipSeparatorInConcatenation }
                            )
                            .flatMap({ $0.stringInterpolation.components })
                    )
                )
            )
        } else {
            result.stringInterpolation.appendInterpolation(
                PromptLiteral(
                    stringInterpolation: PromptLiteral.StringInterpolation(
                        components: literals.flatMap {
                            $0.stringInterpolation.components
                        }
                    )
                )
            )
        }
        
        return result
    }
    
    public static func concatenate(
        separator: Character,
        prefix: String? = nil,
        @_SpecializedArrayBuilder<any PromptLiteralConvertible> _ literals: () throws -> [any PromptLiteralConvertible]
    ) rethrows -> Self {
        try concatenate(separator: separator.stringValue, prefix: prefix, literals)
    }
    
    public static func concatenate(
        separator: Character,
        prefix: String? = nil,
        @_SpecializedArrayBuilder<PromptLiteral> _ literals: () throws -> [PromptLiteral]
    ) rethrows -> Self {
        try concatenate(separator: separator.stringValue, prefix: prefix, literals)
    }
    
    public static func concatenate(
        separator: String?,
        prefix: String? = nil,
        _ literals: [any PromptLiteralConvertible]
    ) -> Self {
        concatenate(separator: separator, prefix: prefix, { literals })
    }
    
    public static func concatenate(
        separator: String?,
        prefix: String? = nil,
        _ literals: [String]
    ) -> Self {
        concatenate(separator: separator, prefix: prefix, literals.map({ PromptLiteral($0) }))
    }
}

extension PromptLiteral {
    public mutating func append(_ other: any PromptLiteralConvertible) {
        stringInterpolation.appendInterpolation(other)
    }
    
    consuming func appending(_ other: any PromptLiteralConvertible) -> Self {
        self.append(other)
        
        return self
    }
    
    public mutating func append(contentsOf other: PromptLiteral) {
        stringInterpolation.appendInterpolation(other)
    }
    
    public func appending(contentsOf other: PromptLiteral) -> Self {
        withMutableScope(self) {
            $0.append(contentsOf: other)
        }
    }
}

extension PromptLiteral {
    public static func + (lhs: Self, rhs: any PromptLiteralConvertible) -> Self {
        lhs.appending(rhs)
    }
    
    @_disfavoredOverload
    public static func + (lhs: any PromptLiteralConvertible, rhs: Self) -> Self {
        PromptLiteral(_lazy: lhs).appending(contentsOf: rhs)
    }
}

extension PromptLiteral {
    public static func == (lhs: Self, rhs: String) throws -> Bool {
        try lhs._stripToText() == rhs
    }
    
    @_disfavoredOverload
    public static func == (lhs: String, rhs: Self) throws -> Bool {
        try rhs == lhs
    }
}

// MARK: - Extensions

extension PromptLiteral {
    public func delimited(
        by character: Character
    ) -> Self {
        let delimiter = PromptLiteral(stringLiteral: String(character))
        
        return delimiter + self + delimiter
    }
}
