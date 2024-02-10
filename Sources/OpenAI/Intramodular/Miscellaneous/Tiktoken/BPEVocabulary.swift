//
// Copyright (c) Vatsal Manot
//

import Swallow

public struct BPEVocabulary {
    public let name: String
    public let url: String
    public let explicitNVocab: Int?
    public let pattern: String
    public let specialTokens: [String: Int]
    
    public init(
        name: String,
        url: String,
        explicitNVocab: Int? = nil,
        pattern: String,
        specialTokens: [String : Int] = [:]
    ) {
        self.name = name
        self.url = url
        self.explicitNVocab = explicitNVocab
        self.pattern = pattern
        self.specialTokens = specialTokens
    }
}

extension BPEVocabulary: CaseIterable {
    public static var allCases: [Self] = [
        .gpt2,
        .r50kBase,
        .p50kBase,
        .p50kEdit,
        .cl100kBase
    ]
}

// MARK: - Auxiliary

public extension BPEVocabulary {
    static var gpt2: BPEVocabulary {
        BPEVocabulary(
            name: "gpt2",
            url: "https://openaipublic.blob.core.windows.net/gpt-2/encodings/main/vocab.bpe",
            explicitNVocab: 50257,
            pattern: "/'s|'t|'re|'ve|'m|'ll|'d| ?\\p{L}+| ?\\p{N}+| ?[^\\s\\p{L}\\p{N}]+|\\s+(?!\\S)|\\s+/gu",
            specialTokens: ["<|endoftext|>": 50256]
        )
    }
    
    static var r50kBase: BPEVocabulary {
        BPEVocabulary(
            name: "r50k_base",
            url: "https://openaipublic.blob.core.windows.net/encodings/r50k_base.tiktoken",
            explicitNVocab: 50257,
            pattern: "/'s|'t|'re|'ve|'m|'ll|'d| ?\\p{L}+| ?\\p{N}+| ?[^\\s\\p{L}\\p{N}]+|\\s+(?!\\S)|\\s+/gu",
            specialTokens: ["<|endoftext|>": 50256]
        )
    }
    
    static var p50kBase: BPEVocabulary {
        .init(
            name: "p50k_base",
            url: "https://openaipublic.blob.core.windows.net/encodings/p50k_base.tiktoken",
            explicitNVocab: 50281,
            pattern: "/'s|'t|'re|'ve|'m|'ll|'d| ?\\p{L}+| ?\\p{N}+| ?[^\\s\\p{L}\\p{N}]+|\\s+(?!\\S)|\\s+/gu",
            specialTokens: ["<|endoftext|>": 50256]
        )
    }
    
    static var p50kEdit: BPEVocabulary {
        BPEVocabulary(
            name: "p50k_edit",
            url: "https://openaipublic.blob.core.windows.net/encodings/p50k_base.tiktoken",
            pattern: "/'s|'t|'re|'ve|'m|'ll|'d| ?\\p{L}+| ?\\p{N}+| ?[^\\s\\p{L}\\p{N}]+|\\s+(?!\\S)|\\s+/gu",
            specialTokens: [
                "<|endoftext|>": 50256,
                "<|fim_prefix|>": 50281,
                "<|fim_middle|>": 50282,
                "<|fim_suffix|>": 50283
            ]
        )
    }
    
    static var cl100kBase: BPEVocabulary {
        BPEVocabulary(
            name: "cl100k_base",
            url: "https://openaipublic.blob.core.windows.net/encodings/cl100k_base.tiktoken",
            pattern: "/(?i:'s|'t|'re|'ve|'m|'ll|'d)|[^\\r\\n\\p{L}\\p{N}]?\\p{L}+|\\p{N}{1,3}| ?[^\\s\\p{L}\\p{N}]+[\\r\\n]*|\\s*[\\r\\n]+|\\s+(?!\\S)|\\s+/gu",
            specialTokens: [
                "<|endoftext|>": 100257,
                "<|fim_prefix|>": 100258,
                "<|fim_middle|>": 100259,
                "<|fim_suffix|>": 100260,
                "<|endofprompt|>": 100276
            ]
        )
    }
}
