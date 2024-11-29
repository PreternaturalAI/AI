//
//  PlayHT.OutputSettings.swift
//  AI
//
//  Created by Jared Davidson on 11/20/24.
//

import Swift

extension PlayHT {
    public struct OutputSettings: Codable, Hashable {
        public let quality: Quality
        public let format: OutputFormat
        public let sampleRate: Int
        
        public init(
            quality: Quality = .medium,
            format: OutputFormat = .mp3,
            sampleRate: Int = 48000
        ) {
            self.quality = quality
            self.format = format
            self.sampleRate = sampleRate
        }
        
        public static let `default` = OutputSettings()
    }
}
