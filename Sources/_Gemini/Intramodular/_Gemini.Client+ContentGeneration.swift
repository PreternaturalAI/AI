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
    static public let configDefault: _Gemini.GenerationConfiguration = .init(
        maxOutputTokens: 8192,
        temperature: 1,
        topP: 0.95,
        topK: 40,
        responseMimeType: "text/plain"
    )
    
    public func generateContent(
        messages: [_Gemini.Message] = [],
        fileSource: _Gemini.FileSource? = nil,
        mimeType: HTTPMediaType? = nil,
        model: _Gemini.Model,
        configuration: _Gemini.GenerationConfiguration = configDefault
    ) async throws -> _Gemini.Content {
        let file: _Gemini.File?
        
        if let fileSource = fileSource {
            file = try await _processedFile(from: fileSource, mimeType: mimeType)
        } else {
            file = nil
        }
        
        let systemInstruction = extractSystemInstruction(from: messages)
        let messages: [_Gemini.Message] = messages.filter({ $0.role != .system })
        var contents: [_Gemini.APISpecification.RequestBodies.Content] = []
        
        if let file {
            guard let mimeType = file.mimeType else {
                throw _Gemini.APIError.unknown(message: "Invalid MIME type")
            }
            
            contents.append(
                _Gemini.APISpecification.RequestBodies.Content(
                    role: "user",
                    parts: [.file(url: file.uri, mimeType: mimeType)]
                )
            )
        }
        
        contents.append(contentsOf: messages.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        })
        
        return try await generateContent(
            contents: contents,
            systemInstruction: systemInstruction,
            model: model,
            configuration: configuration
        )
    }
            
    internal func generateContent(
        contents: [_Gemini.APISpecification.RequestBodies.Content],
        systemInstruction: _Gemini.APISpecification.RequestBodies.Content?,
        model: _Gemini.Model,
        configuration: _Gemini.GenerationConfiguration
    ) async throws -> _Gemini.Content {
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: model,
            requestBody: .init(
                contents: contents,
                generationConfig: configuration,
                systemInstruction: systemInstruction
            )
        )
        
        let response = try await run(\.generateContent, with: input)
       
        return try _Gemini.Content(apiResponse: response)
    }
    
    internal func extractSystemInstruction(
        from messages: [_Gemini.Message]
    ) -> _Gemini.APISpecification.RequestBodies.Content? {
        messages.first { $0.role == .system }.map { message in
            _Gemini.APISpecification.RequestBodies.Content(
                role: message.role.rawValue,
                parts: [.text(message.content)]
            )
        }
    }
}

// MARK: - Error Handling

extension _Gemini.Client {
    fileprivate enum ContentGenerationError: Error {
        case invalidFileName
        case processingTimeout(fileName: String)
        case invalidFileState(state: String)
        case fileNotFound(name: String)
    }
}
