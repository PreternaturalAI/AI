//
// Copyright (c) Preternatural AI, Inc.
//

@_exported import CoreMI
import CorePersistence
@_exported import Diagnostics
@_exported import Merge
@_exported import Swallow
@_exported import SwiftDI

public enum _module {
    public static func initialize() {
        _HadeanSwiftTypeRegistry.register(TextEmbeddings.self)
        _HadeanSwiftTypeRegistry.register(TextEmbeddings.Element.self)
    }
}

extension TaskDependencyValues {
    public var llm: (any LLMRequestHandling)? {
        get {
            self[_OptionalTaskDependencyKey.self]
        } set {
            self[_OptionalTaskDependencyKey.self] = newValue
        }
    }
    
    public var embedding: (any TextEmbeddingsRequestHandling)? {
        get {
            self[_OptionalTaskDependencyKey.self]
        } set {
            self[_OptionalTaskDependencyKey.self] = newValue
        }
    }
}
