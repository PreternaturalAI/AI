//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import LargeLanguageModels
import NetworkKit
import OpenAI
import XCTest

final class TranscriptionTests: XCTestCase {
    @MainActor
    func testTranscription() async throws {
        let transcription = try await client.createTranscription(
            audioFile: "https://replicate.delivery/mgxm/e5159b1b-508a-4be4-b892-e1eb47850bdc/OSR_uk_000_0050_8k.wav",
            prompt: nil,
            model: .whisper_1,
            timestampGranularities: [.word]
        )

        print(transcription.text)
        print(transcription.words)
    }
}
