//
// Copyright (c) Vatsal Manot
//

import Swift

extension OpenAI.Model {
    public static var gpt_3_5: Self {
        .chat(.gpt_3_5_turbo)
    }
    
    public static var gpt_4: Self {
        .chat(.gpt_4)
    }
    
    public static var gpt_4o: Self {
        .chat(.gpt_4o)
    }
}
