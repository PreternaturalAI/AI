//
// Copyright (c) Vatsal Manot
//

@_exported import Diagnostics
@_exported import SwallowMacrosClient

public enum _module {
    
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "CoreMI.Context")
public typealias MIContext = CoreMI._RequestHandlingContext
@available(*, deprecated, renamed: "ModelIdentifier")
public typealias _MLModelIdentifier = ModelIdentifier
@available(*, deprecated, renamed: "ModelIdentifierConvertible")
public typealias _MLModelIdentifierConvertible = ModelIdentifierConvertible
@available(*, deprecated, renamed: "ModelIdentifier.Provider")
public typealias MLModelProvider = ModelIdentifier.Provider
@available(*, deprecated, renamed: "CoreMI._ServiceCredentialProtocol")
public typealias _MIServiceCredential = CoreMI._ServiceCredentialProtocol
