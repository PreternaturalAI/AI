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
    public let base: any CoreMI._ServiceClientProtocol & VideoGenerationRequestHandling
    private let _hashValue: Int
    
//    var displayName: String {
//        switch base {
//            case is FalVideoGenerationRequestHandling:
//                return "Fal"
//            default:
//                fatalError()
//        }
//    }

    public init(
        _ base: any CoreMI._ServiceClientProtocol & VideoGenerationRequestHandling
    ) {
        self.base = base
        self._hashValue = ObjectIdentifier(base as AnyObject).hashValue
    }

    public static func == (lhs: AnyVideoGenerationRequestHandling, rhs: AnyVideoGenerationRequestHandling) -> Bool {
        lhs._hashValue == rhs._hashValue
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }
}
