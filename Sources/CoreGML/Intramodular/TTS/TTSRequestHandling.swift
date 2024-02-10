//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swift

/// A unified interface for a text-to-speech (TTS) service.
public protocol TTSRequestHandling: _MaybeAsyncProtocol {
    func send<R: TTSRequestHandlingRequest>(
        _ request: R
    ) async throws -> R.Result
}

public protocol TTSRequestHandlingRequest: Codable, Hashable, Sendable {
    associatedtype Result: TTSRequestHandlingResult
}

public protocol TTSRequestHandlingResult: Codable, Hashable, Sendable {
    
}

public struct NaiveTTSRequest: TTSRequestHandlingRequest {
    public let text: String
}

extension NaiveTTSRequest {
    public struct Result: TTSRequestHandlingResult {
        public let data: Data
    }
}
