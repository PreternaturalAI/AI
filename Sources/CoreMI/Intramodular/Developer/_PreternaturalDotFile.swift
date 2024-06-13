//
// Copyright (c) Vatsal Manot
//

import CorePersistence

public struct _PreternaturalDotFile: Codable, Hashable, Sendable {
    @FileStorage(
        url: URL.homeDirectory.appending(path: ".preternatural.toml"),
        coder: TOMLCoder()
    )
    public static var dotfileForCurrentUser: Self? = nil

    public var TEST_ANTHROPIC_KEY: String?
    public var TEST_OPENAI_KEY: String?
    
    public func key(
        for provider: ModelIdentifier.Provider
    ) throws -> String? {
        switch provider {
            case .anthropic:
                return TEST_ANTHROPIC_KEY
            case .openAI:
                return TEST_OPENAI_KEY
            default:
                throw Never.Reason.unsupported
        }
    }
    
    @MainActor(unsafe)
    public static func key(
        for provider: ModelIdentifier.Provider
    ) throws -> String? {
        assert(ProcessInfo.processInfo._isRunningWithinXCTest)
        
        return try dotfileForCurrentUser?.key(for: provider)
    }
}
