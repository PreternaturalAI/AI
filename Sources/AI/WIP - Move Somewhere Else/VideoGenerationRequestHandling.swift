//
// Copyright (c) Preternatural AI, Inc.
//

import AVFoundation
import Foundation
import SwiftUI

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
    static let defaultValue: (any VideoGenerationRequestHandling)? = DummyVideoGenerator()
}

extension EnvironmentValues {
    var videoClient: (any VideoGenerationRequestHandling)? {
        get { self[VideoGeneratorKey.self] }
        set { self[VideoGeneratorKey.self] = newValue }
    }
}
