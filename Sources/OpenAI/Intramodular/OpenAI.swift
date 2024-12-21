//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation
import Swift

@RuntimeDiscoverable
public enum OpenAI: _StaticSwift.TypeIterableNamespace {
    public static var _allNamespaceTypes: [any Any.Type] {
        OpenAI.Client.self
    }
}
