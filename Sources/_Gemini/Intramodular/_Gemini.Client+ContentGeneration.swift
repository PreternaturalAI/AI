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
        messages: [_Gemini.Message] = [],
        fileSource: FileSource? = nil,
        mimeType: HTTPMediaType? = nil,
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig = configDefault
    ) async throws -> _Gemini.Content {
        if let fileSource = fileSource {
            return try await handleFileGeneration(
                fileSource: fileSource,
                mimeType: mimeType,
                messages: messages,
                model: model,
                config: config
            )
        }
        
        return try await handleTextOnlyGeneration(
            messages: messages,
            model: model,
            config: config
        )
    }
    
    internal func generateWithFile(
        file: _Gemini.File,
        messages: [_Gemini.Message],
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig
    ) async throws -> _Gemini.Content {
        guard let mimeType = file.mimeType else {
            throw _Gemini.APIError.unknown(message: "Invalid MIME type")
        }
        
        var contents: [_Gemini.APISpecification.RequestBodies.Content] = []
        
        contents.append(_Gemini.APISpecification.RequestBodies.Content(
            role: "user",
            parts: [.file(url: file.uri, mimeType: mimeType)]
        ))
        
        contents.append(contentsOf: messages.filter { $0.role != .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        })
        
        return try await generateContent(
            contents: contents,
            systemInstruction: extractSystemInstruction(from: messages),
            model: model,
            config: config
        )
    }
    
    internal func handleTextOnlyGeneration(
        messages: [_Gemini.Message],
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig
    ) async throws -> _Gemini.Content {
        let contents = messages.filter { $0.role != .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        }
        
        return try await generateContent(
            contents: contents,
            systemInstruction: extractSystemInstruction(from: messages),
            model: model,
            config: config
        )
    }
    
    internal func generateContent(
        contents: [_Gemini.APISpecification.RequestBodies.Content],
        systemInstruction: _Gemini.APISpecification.RequestBodies.Content?,
        model: _Gemini.Model,
        config: _Gemini.GenerationConfig
    ) async throws -> _Gemini.Content {
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
    
    
    internal func extractSystemInstruction(from messages: [_Gemini.Message]) -> _Gemini.APISpecification.RequestBodies.Content? {
        messages.first { $0.role == .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
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

public enum FileSource {
    case localFile(URL)
    case remoteURL(URL)
    case uploadedFile(_Gemini.File)
}
