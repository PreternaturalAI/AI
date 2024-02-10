//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

extension OpenAI.Model {
    var bytePairEncodingVocabulary: BPEVocabulary? {
        if let encodingName = Self.encodingsByModelIdentifier[rawValue], let vocabulary = BPEVocabulary.allCases.first(where: { $0.name == encodingName }) {
            return vocabulary
        }
        
        return Self.findPrefix(with: rawValue)
    }
}

fileprivate extension OpenAI.Model {
    static let encodingsByModelIdentifierPrefix: [String: String] = [
        "gpt-4-": "cl100k_base",  // e.g., gpt-4-0314, etc., plus gpt-4-32k
        "gpt-3.5-turbo-": "cl100k_base",  // e.g, gpt-3.5-turbo-0301, -0401, etc.
    ]
    
    static let encodingsByModelIdentifier: [String: String] = [
        "gpt-4": "cl100k_base",
        "gpt-4-32k": "cl100k_base",
        "gpt-4-1106-preview": "cl100k_base",
        "gpt-4-0125-preview": "cl100k_base",
        "gpt-4-vision-preview": "cl100k_base",
        "gpt-4-0314": "cl100k_base",
        "gpt-4-0613": "cl100k_base",
        "gpt-4-32k-0314": "cl100k_base",
        "gpt-4-32k-0613": "cl100k_base",
        "gpt-3.5-turbo": "cl100k_base",
        "text-davinci-003": "p50k_base",
        "text-davinci-002": "p50k_base",
        "text-davinci-001": "r50k_base",
        "text-curie-001": "r50k_base",
        "text-babbage-001": "r50k_base",
        "text-ada-001": "r50k_base",
        "davinci": "r50k_base",
        "curie": "r50k_base",
        "babbage": "r50k_base",
        "ada": "r50k_base",
        "code-davinci-002": "p50k_base",
        "code-davinci-001": "p50k_base",
        "code-cushman-002": "p50k_base",
        "code-cushman-001": "p50k_base",
        "davinci-codex": "p50k_base",
        "cushman-codex": "p50k_base",
        "text-davinci-edit-001": "p50k_edit",
        "code-davinci-edit-001": "p50k_edit",
        "text-embedding-ada-002": "cl100k_base",
        "text-similarity-davinci-001": "r50k_base",
        "text-similarity-curie-001": "r50k_base",
        "text-similarity-babbage-001": "r50k_base",
        "text-similarity-ada-001": "r50k_base",
        "text-search-davinci-doc-001": "r50k_base",
        "text-search-curie-doc-001": "r50k_base",
        "text-search-babbage-doc-001": "r50k_base",
        "text-search-ada-doc-001": "r50k_base",
        "code-search-babbage-code-001": "r50k_base",
        "code-search-ada-code-001": "r50k_base",
        "gpt2": "gpt2",
        "gpt3": "gpt3",
    ]
    
    private static func findPrefix(
        with name: String
    ) -> BPEVocabulary? {
        guard
            let key = Self.encodingsByModelIdentifierPrefix.keys.first(where: { name.starts(with: $0) }),
            let name = Self.encodingsByModelIdentifierPrefix[key] ,
            let vocabulary = BPEVocabulary.allCases.first(where: { $0.name == name })
        else {
            return nil
        }
        
        return vocabulary
    }
}
