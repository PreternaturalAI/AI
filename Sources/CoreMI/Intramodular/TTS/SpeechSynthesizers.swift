//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

public enum SpeechSynthesizers {
    
}

extension SpeechSynthesizers {
    public protocol VoiceName: Codable, Hashable, Identifiable {
        
    }
}

extension SpeechSynthesizers {
    public struct AnyVoiceName: SpeechSynthesizers.VoiceName {
        public var id: AnyPersistentIdentifier
        public var displayName: String
        public var userInfo: UserInfo
    }
}

