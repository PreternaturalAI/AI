//
// Copyright (c) Vatsal Manot
//

import Foundation
import Swallow

public enum Tiktoken {    
    public static func encoding(
        for model: OpenAI.Model
    ) async throws -> Encoding? {
        guard let vocabulary = model.bytePairEncodingVocabulary else {
            return nil
        }
        
        let encoder = try await loadRanks(vocabulary)
        
        let regex = try NSRegularExpression(pattern: vocabulary.pattern)
        
        let encoding = Encoding(
            name: model.rawValue,
            regex: regex,
            mergeableRanks: encoder,
            specialTokens: vocabulary.specialTokens
        )
        
        return encoding
    }
    
    public static func loadRanks(
        _ vocabulary: BPEVocabulary
    ) async throws -> [[UInt8]: Int] {
        if ["gpt2", "gpt3"].contains(vocabulary.name) {
            return await TokenizerResources.dataGymToMergeableBPERanks(vocabularyBPEFile: vocabulary.url)
        } else {
            return try await TokenizerResources.loadTiktokenBPE(url: vocabulary.url)
        }
    }
}
