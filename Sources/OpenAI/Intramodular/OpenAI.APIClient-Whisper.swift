//
// Copyright (c) Vatsal Manot
//

import Foundation
import LargeLanguageModels
import NetworkKit

extension OpenAI.APIClient {
    public func createTranscription(
        file: Data,
        filename: String,
        preferredMIMEType: HTTPMediaType,
        prompt: String?,
        model: OpenAI.Model.Whisper?,
        language: LargeLanguageModels.ISO639LanguageCode? = nil,
        temperature: Double? = 0,
        timestampGranularities: [OpenAI.AudioTranscription.TimestampGranularity]? = nil,
        responseFormat: OpenAI.APISpecification.RequestBodies.CreateTranscription.ResponseFormat? = nil
    ) async throws -> OpenAI.AudioTranscription {
        let requestBody = OpenAI.APISpecification.RequestBodies.CreateTranscription(
            file: file,
            filename: filename,
            preferredMIMEType: preferredMIMEType,
            prompt: prompt,
            model: OpenAI.Model.whisper(.whisper_1),
            language: language,
            temperature: temperature,
            timestampGranularities: timestampGranularities,
            responseFormat: responseFormat ?? (timestampGranularities == nil ? .text : .verboseJSON)
        )
        
        let response: OpenAI.APISpecification.ResponseBodies.CreateTranscription 
        
        response = try await run(\.createAudioTranscription, with: requestBody)
        
        return OpenAI.AudioTranscription(
            language: response.language,
            duration: response.duration,
            text: response.text,
            words: response.words,
            segments: response.segments
        )
    }
    
    public func createTranscription(
        audioFile: URL,
        prompt: String?,
        model: OpenAI.Model.Whisper?,
        language: LargeLanguageModels.ISO639LanguageCode? = nil,
        temperature: Double? = 0,
        timestampGranularities: [OpenAI.AudioTranscription.TimestampGranularity]? = nil,
        responseFormat: OpenAI.APISpecification.RequestBodies.CreateTranscription.ResponseFormat? = nil
    ) async throws -> OpenAI.AudioTranscription {
        let filename = try audioFile._fileNameWithExtension.unwrap()
        let preferredMIMEType = try audioFile._preferredMIMEType.unwrap()
        let file: Data = try await audioFile._asynchronouslyDownloadContentsOfFile()

        return try await createTranscription(
            file: file,
            filename: filename,
            preferredMIMEType: .init(rawValue: preferredMIMEType),
            prompt: prompt,
            model: model,
            temperature: temperature,
            timestampGranularities: timestampGranularities,
            responseFormat: responseFormat
        )
    }
    
    public func createTranscription(
        audioFile: String,
        prompt: String?,
        model: OpenAI.Model.Whisper?,
        language: LargeLanguageModels.ISO639LanguageCode? = nil,
        temperature: Double? = 0,
        timestampGranularities: [OpenAI.AudioTranscription.TimestampGranularity]? = nil,
        responseFormat: OpenAI.APISpecification.RequestBodies.CreateTranscription.ResponseFormat? = nil
    ) async throws -> OpenAI.AudioTranscription {
        return try await createTranscription(
            audioFile: try URL(string: audioFile).unwrap(),
            prompt: prompt,
            model: model,
            temperature: temperature,
            timestampGranularities: timestampGranularities,
            responseFormat: responseFormat
        )
    }
}
