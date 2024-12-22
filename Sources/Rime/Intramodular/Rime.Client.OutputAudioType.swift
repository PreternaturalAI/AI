//
//  Rime.OutputAudioType.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import Swift

extension Rime.Client {
    public enum StreamOutputAudioType {
        case MP3
        case PCM
        case MULAW
    }
    
    public enum OutputAudioType {
        case MP3
        case WAV
        case OGG
        case MULAW
    }
}
