//
// Copyright (c) Preternatural AI, Inc.
//

import AVFoundation
import Foundation
import SwiftUI
import LargeLanguageModels

public protocol VideoGenerationRequestHandling {
    func availableModels() async throws -> [VideoModel]
    
    func textToVideo(
        text: String,
        model: VideoModel,
        settings: VideoGenerationSettings
    ) async throws -> Data
    
    func imageToVideo(
        imageURL: URL,
        model: VideoModel,
        settings: VideoGenerationSettings
    ) async throws -> Data
    
    func videoToVideo(
        videoURL: URL,
        prompt: String,
        model: VideoModel,
        settings: VideoGenerationSettings
    ) async throws -> Data
}

private struct VideoGeneratorKey: EnvironmentKey {
    public static let defaultValue: (any VideoGenerationRequestHandling)? = nil
}

extension EnvironmentValues {
    public var videoClient: (any VideoGenerationRequestHandling)? {
        get { self[VideoGeneratorKey.self] }
        set { self[VideoGeneratorKey.self] = newValue }
    }
}

public struct AnyVideoGenerationRequestHandling: Hashable {
    private let _service: any CoreMI._ServiceClientProtocol
    private let _base: any VideoGenerationRequestHandling
    private let _hashValue: Int

    public init(
        _ base: any VideoGenerationRequestHandling,
        service: any CoreMI._ServiceClientProtocol
    ) {
        self._base = base
        self._hashValue = ObjectIdentifier(base as AnyObject).hashValue
        self._service = service
    }

    public static func == (lhs: AnyVideoGenerationRequestHandling, rhs: AnyVideoGenerationRequestHandling) -> Bool {
        lhs._hashValue == rhs._hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }

    public func base() -> any VideoGenerationRequestHandling {
        _base
    }
}
