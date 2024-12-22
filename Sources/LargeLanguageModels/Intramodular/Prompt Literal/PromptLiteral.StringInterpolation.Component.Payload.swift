//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import FoundationX
import Swallow
import SwiftUIX

extension PromptLiteral.StringInterpolation.Component {
    public enum Payload: _CasePathExtracting, HashEquatable, @unchecked Sendable {
        case stringLiteral(String)
        case image(Image)
        case localizedStringResource(LocalizedStringResource)
        case promptLiteralConvertible(any PromptLiteralConvertible)
        case dynamicVariable(any _opaque_DynamicPromptVariable)
        case other(Other)
        
        var _isImage: Bool {
            guard case .image = self else {
                return false
            }
            
            return true
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload {
    public var _isEmpty: Bool {
        get throws {
            switch self {
                case .stringLiteral(let string):
                    return string.isEmpty
                case .image:
                    return false
                case .localizedStringResource(let string):
                    return try string._toNSLocalizedString().isEmpty == true
                case .promptLiteralConvertible(let literal):
                    return try literal.promptLiteral.isEmpty
                case .dynamicVariable(let variable):
                    return try variable._isEmpty
                case .other:
                    return false
            }
        }
    }
    
    public var functionCall: AbstractLLM.ChatFunctionCall? {
        get {
            self[casePath: /Self.other]?[casePath: /Other.functionCall]
        } set {
            self = try! .other(.functionCall(newValue.unwrap()))
        }
    }
    
    public var functionInvocation: AbstractLLM.ResultOfFunctionCall? {
        get {
            self[casePath: /Self.other]?[casePath: /Other.functionInvocation]
        } set {
            self = try! .other(.functionInvocation(newValue.unwrap()))
        }
    }
}

// MARK: - Conformances

extension PromptLiteral.StringInterpolation.Component.Payload: Codable {
    public init(from decoder: Decoder) throws {
        if let value = try? String(from: decoder) {
            self = .stringLiteral(value)
        } else {
            throw Never.Reason.unimplemented
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
            case .stringLiteral(let value):
                try value.encode(to: encoder)
            default:
                throw Never.Reason.unimplemented
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload: CustomDebugStringConvertible {
    public var _debugDescription: String {
        get throws {
            switch self {
                case .stringLiteral(let string):
                    return string
                case .image:
                    return "<image>"
                case .localizedStringResource(let string):
                    return try string._toNSLocalizedString()
                case .promptLiteralConvertible(let literal):
                    return try literal.promptLiteral.debugDescription
                case .dynamicVariable(let variable):
                    return try variable.promptLiteral.debugDescription
                case .other(let value):
                    switch value {
                        case .functionCall(let call):
                            return call.debugDescription
                        case .functionInvocation(let invocation):
                            return invocation.debugDescription
                    }
            }
        }
    }
    
    public var debugDescription: String {
        do {
            return try _debugDescription
        } catch {
            return "<error>"
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload: Hashable {
    public func hash(into hasher: inout Hasher) {
        do {
            try _HashableExistential(erasing: value).hash(into: &hasher)
        } catch {
            assertionFailure()
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload: ThrowingRawValueConvertible {
    public typealias RawValue = Any
    
    public var rawValue: Any {
        get throws {
            switch self {
                case .stringLiteral(let value):
                    return value
                case .image(let value):
                    assertionFailure()
                    
                    return value
                case .localizedStringResource(let value):
                    return value
                case .promptLiteralConvertible(let value):
                    return value
                case .dynamicVariable(let variable):
                    return variable
                case .other(let other):
                    return other.rawValue
            }
        }
    }
    
    public var value: Any {
        get throws {
            switch self {
                case .stringLiteral(let value):
                    return value
                case .image(let value):
                    return value
                case .localizedStringResource(let value):
                    return try value._toNSLocalizedString()
                case .promptLiteralConvertible(let value):
                    return try value.promptLiteral
                case .dynamicVariable:
                    assertionFailure()
                    
                    throw Never.Reason.illegal
                case .other(let other):
                    return other.value
            }
        }
    }
}

// MARK: - Auxiliary

extension PromptLiteral.StringInterpolation.Component.Payload {
    public enum Image: Hashable, Sendable {
        case image(_AnyImage)
        case base64DataURL(Base64DataURL)
        case url(URL)
    }
    
    public enum Other: _CasePathExtracting, Hashable, Sendable {
        case functionCall(AbstractLLM.ChatFunctionCall)
        case functionInvocation(AbstractLLM.ResultOfFunctionCall)
        
        var rawValue: any Hashable {
            switch self {
                case .functionCall(let call):
                    return call
                case .functionInvocation(let invocation):
                    return invocation
            }
        }
        
        var value: any Hashable {
            rawValue
        }
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload.Image {
    public func toBase64DataURL() async throws -> Base64DataURL {
        switch self {
            case .image(let image):
                return try Base64DataURL(image: image.jpegData.unwrap())
            case .base64DataURL(let url):
                return url
            case .url(let url):
                return try await Base64DataURL(imageURL: url)
        }
    }
    
    @MainActor
    public func _toAppKitOrUIKitImage() async throws -> SwiftUIX._AnyImage {
        let data: Data = try await toBase64DataURL().data
        
        return try _AnyImage(AppKitOrUIKitImage(data: data).unwrap())
    }
}
