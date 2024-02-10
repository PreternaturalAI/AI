//
// Copyright (c) Vatsal Manot
//

import Swallow

public protocol _GMLModelIdentifierConvertible {
    func __conversion() throws -> _GMLModelIdentifier
}

public protocol _GMLModelIdentifierRepresentable: _GMLModelIdentifierConvertible {
    init(from _: _GMLModelIdentifier) throws
}
