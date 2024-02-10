//
// Copyright (c) Vatsal Manot
//

import Foundation
import LargeLanguageModels
import Swallow

extension Tiktoken {
    public class Encoding {
        typealias Ranks = [[UInt8]: Int]
            
        private let name: String
        private let regex: NSRegularExpression // Regex
        private let mergeableRanks: [[UInt8]: Int]
        private let specialTokens: [String: Int]
        private let maxValueToken: Int
        
        private let coreBPE: CoreBPE
        
        init(
            name: String,
            regex: NSRegularExpression,
            mergeableRanks: [[UInt8]: Int],
            specialTokens: [String: Int],
            explicitNVocab: Int? = nil
        ) {
            self.name = name
            self.regex = regex
            self.mergeableRanks = mergeableRanks
            self.specialTokens = specialTokens
            self.maxValueToken = max(mergeableRanks.values.max() ?? 0, specialTokens.values.max() ?? 0)
            
            let decoder = mergeableRanks.inverted

            self.coreBPE = .init(encoder: mergeableRanks, decoder: decoder, regexTls: [regex])
        }
    }
}

extension Tiktoken.Encoding {
    public func encode(_ text: String) -> [Int] {
        coreBPE.encodeOrdinaryNative(text: text)
    }
    
    public func decode(_ value: [Int]) -> String {
        coreBPE.decodeNative(tokens: value)
    }
}

extension Tiktoken.Encoding.Ranks {
    var inverted: [Int: [UInt8]] {
        reduce(into: [:], { $0[$1.value] = $1.key })
    }
}
