//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension NeetsAI {
    public struct Voice: Codable, Hashable {
        public let id: String
        public let title: String?
        public let aliasOf: String?
        public let supportedModels: [String]
    }
}
