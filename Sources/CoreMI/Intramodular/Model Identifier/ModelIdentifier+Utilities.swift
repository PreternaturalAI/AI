//
// Copyright (c) Vatsal Manot
//

import Swift

extension ModelIdentifier {
    static func _guessPrimaryProvider(
        forRawIdentifier identifier: String
    ) -> ModelIdentifier.Provider? {
        if _Anthropic_Model(rawValue: identifier) != nil {
            return ._Anthropic
        } else if _Mistral_Model(rawValue: identifier) != nil {
            return ._Mistral
        } else if _OpenAI_Model(rawValue: identifier) != nil {
            return ._OpenAI
        }
        
        if identifier.hasPrefix("claude") {
            return ._Anthropic
        }
        
        if identifier.hasPrefix("mistral") {
            return ._Mistral
        }
        
        return nil
    }
}

extension ModelIdentifier {
    private enum _Anthropic_Model: String, CaseIterable {
        case claude_instant_v1 = "claude-instant-v1"
        case claude_v1 = "claude-v1"
        case claude_v2 = "claude-2"
        
        case claude_instant_v1_0 = "claude-instant-v1.0"
        case claude_instant_v1_2 = "claude-instant-v1.2"
        case claude_v1_0 = "claude-v1.0"
        case claude_v1_2 = "claude-v1.2"
        case claude_v1_3 = "claude-v1.3"
        case claude_3_haiku_20240307 = "claude-3-haiku-20240307"
        case claude_3_sonnet_20240229 = "claude-3-sonnet-20240229"
        case claude_3_opus_20240229 = "claude-3-opus-20240229"
    }
    
    private enum _Mistral_Model: String, CaseIterable {
        case mistral_tiny = "mistral-tiny"
        case mistral_small = "mistral-small"
        case mistral_medium = "mistral-medium"
    }
    
    private enum _OpenAI_Model: String, CaseIterable {
        case text_embedding_ada_002 = "text-embedding-ada-002"
        case text_embedding_3_small = "text-embedding-3-small"
        case text_embedding_3_large = "text-embedding-3-large"
        
        case gpt_3_5_turbo = "gpt-3.5-turbo"
        case gpt_3_5_turbo_16k = "gpt-3.5-turbo-16k"
        case gpt_4 = "gpt-4"
        case gpt_4_32k = "gpt-4-32k"
        case gpt_4_1106_preview = "gpt-4-1106-preview"
        case gpt_4_0125_preview = "gpt-4-0125-preview"
        case gpt_4_vision_preview = "gpt-4-vision-preview"
        case gpt_3_5_turbo_0301 = "gpt-3.5-turbo-0301"
        case gpt_3_5_turbo_0613 = "gpt-3.5-turbo-0613"
        case gpt_3_5_turbo_16k_0613 = "gpt-3.5-turbo-16k-0613"
        case gpt_4_0314 = "gpt-4-0314"
        case gpt_4_0613 = "gpt-4-0613"
        case gpt_4_32k_0314 = "gpt-4-32k-0314"
        case gpt_4_32k_0613 = "gpt-4-32k-0613"
        case gpt_4o = "gpt-4o"
    }
}
