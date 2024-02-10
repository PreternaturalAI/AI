//
// Copyright (c) Vatsal Manot
//

import CoreGML
import CorePersistence
import Merge
import Swallow

/// A type that provides text embeddings for text.
public protocol TextEmbeddingsRequestHandling {
    var _availableModels: [_GMLModelIdentifier]? { get }
    
    func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings
}

// MARK: - Extensions

extension TextEmbeddingsRequestHandling {
    public var _availableModels: [_GMLModelIdentifier]? {
        nil
    }
    
    public func textEmbeddings(
        for strings: [String]
    ) async throws -> TextEmbeddings {
        try await self.fulfill(
            TextEmbeddingsRequest(
                model: nil,
                strings: strings
            )
        )
    }
    
    public func textEmbeddings(
        for strings: [String],
        model: some _GMLModelIdentifierConvertible
    ) async throws -> TextEmbeddings {
        try await self.fulfill(
            TextEmbeddingsRequest(
                model: try model.__conversion(),
                strings: strings
            )
        )
    }
    
    public func textEmbedding(
        for string: String
    ) async throws -> _RawTextEmbedding {
        try await self.fulfill(
            TextEmbeddingsRequest(model: nil, strings: [string])
        )
        .data
        .toCollectionOfOne()
        .value
        .embedding
    }
    
    public func textEmbedding(
        for string: String,
        model: some _GMLModelIdentifierConvertible
    ) async throws -> _RawTextEmbedding {
        try await self.fulfill(
            TextEmbeddingsRequest(model: model.__conversion(), strings: [string])
        )
        .data
        .toCollectionOfOne()
        .value
        .embedding
    }
}

// MARK: - Diagnostics

public enum TextEmbeddingsRequestHandlingError: Error {
    case tokenLimitExceeded
}

// MARK: - Auxiliary

/// A request to generate text embeddings.
public struct TextEmbeddingsRequest {
    public let input: [String]
    public let model: _GMLModelIdentifier?
    
    public init(
        input: [String],
        model: _GMLModelIdentifier?
    ) {
        self.input = input
        self.model = model
    }
        
    public func batched(batchSize: Int) -> [Self] {
        input.chunked(by: batchSize).map { chunk in
            Self(
                input: Array(chunk),
                model: model
            )
        }
    }
}

// MARK: - Deprecated

@available(*, deprecated, renamed: "TextEmbeddingsRequestHandling")
public typealias TextEmbeddingsProvider = TextEmbeddingsRequestHandling

extension TextEmbeddingsRequest {
    @available(*, deprecated, renamed: "strings")
    public var strings: [String] {
        input
    }
    
    public init(
        model: _GMLModelIdentifier?,
        strings: [String]
    ) {
        self.input = strings
        self.model = model
    }
}
