//
// Copyright (c) Vatsal Manot
//

import Swallow
import CoreML

extension _GMLModel {
    public struct HumanReadableDescription: Codable, Hashable, Sendable {
        public let rawValue: [Descriptor]
        
        public init(rawValue: [Descriptor]) {
            self.rawValue = rawValue
        }
    }
}

extension _GMLModel.HumanReadableDescription {
    public enum Descriptor: Codable, Hashable, Sendable {
        public enum _TypeDescriptor: String, Codable, Hashable, Sendable {
            case largeLanguageModel = "llm"
            case embeddingModel = "embedding"
        }
        
        case type(_TypeDescriptor)
    }
}
