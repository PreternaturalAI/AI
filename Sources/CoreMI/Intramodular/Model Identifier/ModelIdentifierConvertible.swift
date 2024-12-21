//
// Copyright (c) Preternatural AI, Inc.
//

import Swallow

public protocol ModelIdentifierConvertible {
    func __conversion() throws -> ModelIdentifier
}

public protocol ModelIdentifierRepresentable: ModelIdentifierConvertible {
    init(from _: ModelIdentifier) throws
}
