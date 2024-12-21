//
// Copyright (c) Preternatural AI, Inc.
//

import Swallow

public protocol _opaque_DynamicPromptVariable: PromptLiteralConvertible {
    associatedtype ResolvedValue
    
    var _runtimeResolvedValue: ResolvedValue? { get }
    var _isEmpty: Bool { get throws }
}
