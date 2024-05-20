//
// Copyright (c) Vatsal Manot
//

import SwiftUIX

public struct ChatCompletionDecodableResultType<T: AbstractLLM.ChatCompletionDecodable> {
    fileprivate init() {
        
    }
}

extension ChatCompletionDecodableResultType where T == String {
    public static var string: Self {
        .init()
    }
}
