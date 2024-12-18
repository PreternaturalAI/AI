//
//  _Gemini.Client+ContentGeneration.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Foundation
import SwiftAPI
import Merge
import FoundationX
import Swallow

extension _Gemini.Client {
    static public let configDefault: _Gemini.GenerationConfig = .init(
        maxOutputTokens: 8192,
        temperature: 1,
        topP: 0.95,
        topK: 40,
        responseMimeType: "text/plain"
    )
    
    public func generateContent(
        url: URL,
        type: HTTPMediaType,
        prompt: String,
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig = configDefault
    ) async throws -> _Gemini.Content {
        do {
            let data = try Data(contentsOf: url)
            
            let uploadedFile = try await uploadFile(
                fileData: data,
                mimeType: type,
                displayName: UUID().uuidString
            )
            
            return try await self.generateContent(
                file: uploadedFile,
                prompt: prompt,
                model: model,
                config: config
            )
        } catch let error as NSError where error.domain == NSCocoaErrorDomain {
            throw _Gemini.APIError.unknown(message: "Failed to read file: \(error.localizedDescription)")
        } catch {
            throw error
        }
    }
    
    public func generateContent(
        file: _Gemini.File,
        prompt: String,
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig = configDefault
    ) async throws -> _Gemini.Content {
        guard let fileName = file.name else {
            throw ContentGenerationError.invalidFileName
        }
        
        do {
            print("Waiting for file processing...")
            let processedFile = try await waitForFileProcessing(name: fileName)
            print("File processing complete: \(processedFile)")
            
            guard let mimeType = file.mimeType else {
                throw _Gemini.APIError.unknown(message: "Invalid MIME type")
            }
            
            let fileUri = processedFile.uri
            
            let fileContent = _Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [
                    .file(url: fileUri, mimeType: mimeType),
                ]
            )
            
            let promptContent = _Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [
                    .text(prompt)
                ]
            )
            
            let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
                model: model,
                requestBody: .init(
                    contents: [fileContent, promptContent],
                    generationConfig: config
                )
            )
            
            print(input)
            
            let response = try await run(\.generateContent, with: input)
            
            return try _Gemini.Content.init(apiResponse: response)

        } catch let error as ContentGenerationError {
            throw error
        } catch {
            throw _Gemini.APIError.unknown(message: "Content generation failed: \(error.localizedDescription)")
        }
    }
}

// Error Handling

fileprivate enum ContentGenerationError: Error {
    case invalidFileName
    case processingTimeout(fileName: String)
    case invalidFileState(state: String)
    case fileNotFound(name: String)
}
