//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import Merge
import Swallow

/// A type that provides text embeddings for text.
public protocol TextEmbeddingsRequestHandling {
    var _availableModels: [_MLModelIdentifier]? { get }
    
    func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings
}

extension MIContext {
    /// Complete a given prompt.
    public func fulfill(
        _ request: TextEmbeddingsRequest
    ) async throws -> TextEmbeddings {
        let textEmbedder = try await _firstHandler(ofType: TextEmbeddingsRequestHandling.self)
        
        return try await textEmbedder.fulfill(request)
    }
}

// MARK: - Extensions

extension TextEmbeddingsRequestHandling {
    public var _availableModels: [_MLModelIdentifier]? {
        nil
    }
    
    /// Produce an array of text embeddings for the given array of strings.
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
    
    /// Produce an array of text embeddings for the given array of strings.
    public func textEmbeddings(
        for strings: [String],
        model: some _MLModelIdentifierConvertible
    ) async throws -> TextEmbeddings {
        try await self.fulfill(
            TextEmbeddingsRequest(
                model: try model.__conversion(),
                strings: strings
            )
        )
    }
    
    /// Produce a single text embedding for the given text.
    public func singleTextEmbedding(
        for string: String
    ) async throws -> SingleTextEmbedding {
        let embeddings: TextEmbeddings = try await self.fulfill(
            TextEmbeddingsRequest(model: nil, strings: [string])
        )
        
        let result: SingleTextEmbedding = try embeddings.data.toCollectionOfOne().first
        
        return result
    }
    
    /// Produce a single text embedding for the given text.
    @available(*, deprecated, renamed: "singleTextEmbedding")
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
        model: some _MLModelIdentifierConvertible
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
    public let model: _MLModelIdentifier?
    
    public init(
        input: [String],
        model: _MLModelIdentifier?
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
        model: _MLModelIdentifier?,
        strings: [String]
    ) {
        self.input = strings
        self.model = model
    }
}
