//
// Copyright (c) Vatsal Manot
//

import Swift

extension Anthropic.Model {
    public static var haiku: Self {
        .claude_3_haiku_20240307
    }
    
    public static var sonnet: Self {
        .claude_3_sonnet_20240229
    }
    
    public static var opus: Self {
        .claude_3_opus_20240229
    }
}
