//
//  ElevenLabs.Client+Dubbing.swift
//  AI
//
//  Created by Jared Davidson on 1/7/25.
//

import Foundation

extension ElevenLabs.Client {
    public func dub(
        fileData: Data? = nil,
        sourceURL: URL? = nil,
        name: String? = nil,
        sourceLang: String? = nil,
        targetLang: String,app
        numSpeakers: Int? = nil,
        options: DubbingOptions = .init(),
        progress: @escaping (DubbingProgress) async -> Void
    ) async throws -> DubbingResult {
        guard fileData != nil || sourceURL != nil else {
            throw NSError(domain: "ElevenLabs", code: -1, userInfo: [
                NSLocalizedDescriptionKey: "Either fileData or sourceURL must be provided"
            ])
        }
        
        let request = ElevenLabs.APISpecification.RequestBodies.DubbingRequest(
            name: name,
            sourceURL: sourceURL,
            sourceLang: sourceLang,
            targetLang: targetLang,
            numSpeakers: numSpeakers,
            watermark: options.watermark,
            startTime: options.startTime,
            endTime: options.endTime,
            highestResolution: options.highestResolution,
            dropBackgroundAudio: options.dropBackgroundAudio,
            useProfanityFilter: options.useProfanityFilter,
            fileData: fileData
        )
        
        // Start dubbing process
        let response = try await run(\.initiateDubbing, with: request)
        let dubbingId = response.dubbingId
        let expectedDuration = response.expectedDurationSec
        
        // Poll for status
        let pollingInterval: TimeInterval = 5 // seconds
        let maxAttempts = Int(ceil(expectedDuration / pollingInterval)) + 10 // Add some buffer attempts
        
        for _ in 0..<maxAttempts {
            let status = try await run(\.getDubbingStatus, with: dubbingId)
            
            // Send progress update
            await progress(DubbingProgress(
                status: status,
                expectedDuration: expectedDuration,
                dubbingId: dubbingId
            ))
            
            switch status.state {
                case .completed:
                    let data = try await run(\.getDubbingResult, with: dubbingId)
                    return DubbingResult(
                        data: data,
                        dubbingId: dubbingId,
                        totalDuration: expectedDuration
                    )
                case .failed:
                    throw NSError(domain: "ElevenLabs", code: -1, userInfo: [
                        NSLocalizedDescriptionKey: status.failure_reason ?? "Unknown error occurred during dubbing"
                    ])
                case .processing:
                    try await Task.sleep(nanoseconds: UInt64(pollingInterval * 1_000_000_000))
                    continue
            }
        }
        
        throw NSError(domain: "ElevenLabs", code: -1, userInfo: [
            NSLocalizedDescriptionKey: "Dubbing timed out"
        ])
    }
}
