//
//  AnySpeechSynthesisRequestHandling.swift
//  AI
//
//  Created by Jared Davidson on 1/14/25.
//

import ElevenLabs
import LargeLanguageModels

public struct AnySpeechSynthesisRequestHandling: Hashable {
    private let _hashValue: Int
    
    public let base: any CoreMI._ServiceClientProtocol & SpeechSynthesisRequestHandling
    
    public var displayName: String {
        switch base {
            case is ElevenLabs.Client:
                return "ElevenLabs"
            default:
                fatalError()
        }
    }
    
    public init(
        _ base: any CoreMI._ServiceClientProtocol & SpeechSynthesisRequestHandling
    ) {
        self.base = base
        self._hashValue = ObjectIdentifier(base as AnyObject).hashValue
    }
    
    public static func == (lhs: AnySpeechSynthesisRequestHandling, rhs: AnySpeechSynthesisRequestHandling) -> Bool {
        lhs._hashValue == rhs._hashValue
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(_hashValue)
    }
}
