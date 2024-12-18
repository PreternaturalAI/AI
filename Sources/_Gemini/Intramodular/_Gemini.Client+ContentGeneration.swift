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
    
    // FIXME: - I'm not sure where/how a default should be properly placed.
    static public let configDefault: _Gemini.GenerationConfig = .init(
        maxOutputTokens: 8192,
        temperature: 1,
        topP: 0.95,
        topK: 40,
        responseMimeType: "text/plain"
    )
    
    public func generateContent(
        messages: [_Gemini.Message] = [],
        file: _Gemini.File? = nil,
        fileURL: URL? = nil,
        mimeType: HTTPMediaType? = nil,
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig = configDefault
    ) async throws -> _Gemini.Content {
        // Handle file URL if provided
        if let fileURL = fileURL {
            guard let mimeType = mimeType else {
                throw _Gemini.APIError.unknown(message: "MIME type is required when using fileURL")
            }
            
            do {
                let data = try Data(contentsOf: fileURL)
                let uploadedFile = try await uploadFile(
                    fileData: data,
                    mimeType: mimeType,
                    displayName: UUID().uuidString
                )
                return try await generateContent(
                    messages: messages,
                    file: uploadedFile,
                    model: model,
                    config: config
                )
            } catch let error as NSError where error.domain == NSCocoaErrorDomain {
                throw _Gemini.APIError.unknown(message: "Failed to read file: \(error.localizedDescription)")
            }
        }
        
        // Handle file if provided
        if let file = file {
            guard let fileName = file.name else {
                throw ContentGenerationError.invalidFileName
            }
            
            let processedFile = try await waitForFileProcessing(name: fileName)
            
            guard let mimeType = file.mimeType else {
                throw _Gemini.APIError.unknown(message: "Invalid MIME type")
            }
            
            var contents: [_Gemini.APISpecification.RequestBodies.Content] = []
            
            // Add file content first if present
            contents.append(_Gemini.APISpecification.RequestBodies.Content(
                role: "user",
                parts: [.file(url: processedFile.uri, mimeType: mimeType)]
            ))
            
            // Add regular messages
            contents.append(contentsOf: messages.filter { $0.role != .system }.map { message in
                _Gemini.APISpecification.RequestBodies.Content(
                    role: message.role.rawValue,
                    parts: [.text(message.content)]
                )
            })
            
            let systemInstruction = messages.first { $0.role == .system }.map { message in
                _Gemini.APISpecification.RequestBodies.Content(
                    role: message.role.rawValue,
                    parts: [.text(message.content)]
                )
            }
            
            let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
                model: model,
                requestBody: .init(
                    contents: contents,
                    generationConfig: config,
                    systemInstruction: systemInstruction
                )
            )
            
            let response = try await run(\.generateContent, with: input)
            return try _Gemini.Content(apiResponse: response)
        }
        
        // Handle text-only messages
        let contents = messages.filter { $0.role != .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        }
        
        let systemInstruction = messages.first { $0.role == .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        }
        
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: model,
            requestBody: .init(
                contents: contents,
                generationConfig: config,
                systemInstruction: systemInstruction
            )
        )
        
        let response = try await run(\.generateContent, with: input)
        return try _Gemini.Content(apiResponse: response)
    }
}

// Error Handling

fileprivate enum ContentGenerationError: Error {
    case invalidFileName
    case processingTimeout(fileName: String)
    case invalidFileState(state: String)
    case fileNotFound(name: String)
}
