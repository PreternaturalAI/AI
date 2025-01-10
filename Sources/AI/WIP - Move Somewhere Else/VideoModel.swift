//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Foundation

public struct VideoModel: Codable, Hashable, Identifiable {
    public typealias ID = _TypeAssociatedID<Self, UUID>

    public let id: ID
    public let endpoint: String
    public let name: String
    public let description: String?
    public let capabilities: [Capability]
    
    public enum Capability: String, Codable {
        case textToVideo
        case imageToVideo
        case videoToVideo
    }
    
    public init(
        endpoint: String,
        name: String,
        description: String?,
        capabilities: [Capability]
    ) {
        self.id = .random()
        self.endpoint = endpoint
        self.name = name
        self.description = description
        self.capabilities = capabilities
    }
}
