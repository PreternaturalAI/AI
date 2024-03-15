//
// Copyright (c) Vatsal Manot
//

import Expansions
import Swift

@RuntimeDiscoverable
public enum OpenAI: _TypeIterableStaticNamespaceType {
    public static var _allNamespaceTypes: [any Any.Type] {
        OpenAI.APIClient.self
    }
}
