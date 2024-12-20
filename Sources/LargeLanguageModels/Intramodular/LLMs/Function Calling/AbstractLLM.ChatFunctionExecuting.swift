//
// Copyright (c) Vatsal Manot
//

import Compute
import Foundation
import Swallow

/// A type that asynchronously handles function calls.
///
/// This type is **WIP**.
public protocol __AbstractLLM_ChatFunctionExecuting {
    func execute(
        _ call: AbstractLLM.ChatFunctionCall
    ) async throws -> AbstractLLM.ResultOfFunctionCall
}
