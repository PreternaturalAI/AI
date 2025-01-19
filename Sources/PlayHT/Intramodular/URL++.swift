//
//  URL++.swift
//  AI
//
//  Created by Jared Davidson on 1/14/25.
//

import AVFoundation
import AudioToolbox

// FIXME: - This needs to be moved somewhere else (@archetapp)

extension URL {
    func convertAudioToMP4() async throws -> URL {
        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("mp4")
        
        let asset = AVURLAsset(url: self)
        
        let composition = AVMutableComposition()
        guard let compositionTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw NSError(domain: "AudioConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create composition track"])
        }
        
        guard let audioTrack = try await asset.loadTracks(withMediaType: .audio).first else {
            throw NSError(domain: "AudioConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "No audio track found"])
        }
        
        let timeRange = CMTimeRange(start: .zero, duration: try await asset.load(.duration))
        for i in 0..<4 {
            try compositionTrack.insertTimeRange(
                timeRange,
                of: audioTrack,
                at: CMTime(seconds: Double(i) * timeRange.duration.seconds, preferredTimescale: 600)
            )
        }
        
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetPassthrough
        ) else {
            throw NSError(domain: "AudioConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Could not create export session"])
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
        // Create a tuple of values we need to check after export
        try await withCheckedThrowingContinuation { continuation in
            let mainQueue = DispatchQueue.main
            exportSession.exportAsynchronously {
                mainQueue.async {
                    switch exportSession.status {
                    case .completed:
                        continuation.resume()
                    case .failed:
                        continuation.resume(throwing: exportSession.error ?? NSError(domain: "AudioConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export failed"]))
                    case .cancelled:
                        continuation.resume(throwing: NSError(domain: "AudioConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Export cancelled"]))
                    default:
                        continuation.resume(throwing: NSError(domain: "AudioConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown export error"]))
                    }
                }
            }
        }
        
        let fileSize = try FileManager.default.attributesOfItem(atPath: outputURL.path)[.size] as? Int ?? 0
        if fileSize < 5000 { // 5KB minimum
            throw NSError(domain: "AudioConversion", code: -1, userInfo: [NSLocalizedDescriptionKey: "Converted file too small"])
        }
        
        return outputURL
    }
}
