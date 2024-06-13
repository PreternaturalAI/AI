//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import Swallow

/// A type that represents an array of text+embedding pairs.
///
/// Text embeddings are vector representations of text.
///
/// You can produce text embeddings by using a text embedding model (for e.g. OpenAI's `text-embedding-ada-002`).
public struct TextEmbeddings: Codable, HadeanIdentifiable, Hashable, Sendable {
    public typealias Element = SingleTextEmbedding
    
    public static var hadeanIdentifier: HadeanIdentifier {
        "junur-tutuz-zarik-ninab"
    }
    
    public let data: [SingleTextEmbedding]
    public let model: ModelIdentifier
    
    public init(
        model: ModelIdentifier,
        data: [SingleTextEmbedding]
    ) {
        self.model = model
        self.data = data
    }
}

extension TextEmbeddings {
    public func appending(
        contentsOf other: TextEmbeddings
    ) -> Self {
        assert(model == other.model)
        
        return .init(
            model: model,
            data: data.appending(contentsOf: other.data)
        )
    }
}

// MARK: - Conformances

extension TextEmbeddings: RandomAccessCollection {
    public var startIndex: Int {
        data.startIndex
    }
    
    public var endIndex: Int {
        data.endIndex
    }

    public subscript(_ index: Int) -> Element {
        data[index]
    }
    
    public func makeIterator() -> AnyIterator<Element> {
        data.makeIterator().eraseToAnyIterator()
    }
}
