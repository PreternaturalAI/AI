//
// Copyright (c) Preternatural AI, Inc.
//

import Diagnostics
import Swallow

public enum PromptLiteralError: Error {
    case failedToReduceToPrompt(for: AbstractLLM.CompletionType?)
}
