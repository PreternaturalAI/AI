//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension _Gemini {
    public struct TuningOperation: Codable {
        public let name: String
        public let metadata: TuningMetadata?
        public let error: TuningError?
        
        // Computed property for done state since it's not in initial response
        public var done: Bool {
            // Operation is done if we have a tunedModel in metadata
            
            return metadata?.tunedModel != nil
        }
        
        public struct TuningMetadata: Codable {
            public let totalSteps: Int
            public let tunedModel: String?
            
            private enum CodingKeys: String, CodingKey {
                case totalSteps
                case tunedModel
                case type = "@type"
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                self.totalSteps = try container.decode(Int.self, forKey: .totalSteps)
                self.tunedModel = try container.decodeIfPresent(String.self, forKey: .tunedModel)
                // Ignore the @type field as we don't need it
                _ = try container.decodeIfPresent(String.self, forKey: .type)
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.container(keyedBy: CodingKeys.self)
                try container.encode(totalSteps, forKey: .totalSteps)
                try container.encodeIfPresent(tunedModel, forKey: .tunedModel)
                try container.encode("type.googleapis.com/google.ai.generativelanguage.v1beta.CreateTunedModelMetadata", forKey: .type)
            }
        }
        
        public struct TuningError: Codable {
            public let code: Int
            public let message: String
            public let details: [String: String]
        }
    }
}
