//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import Swift

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
    
    public protocol _AnyVoiceNameInitiable {
        init(voice: SpeechSynthesizers.AnyVoiceName) throws
    }
    
    public protocol _AnyVoiceNameConvertible {
        func __conversion() throws -> SpeechSynthesizers.AnyVoiceName
    }
}
