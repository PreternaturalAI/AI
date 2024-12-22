//
//  HumeAI.Voice.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import Foundation

extension HumeAI {
    public struct Voice: Hashable, Codable {
        public var id: String
        public var name: String
        public var baseVoice: String
        public var parameterModel: String
        public var parameters: Parameters?
        public var createdOn: Int64
        public var modifiedOn: Int64
        
        public struct Parameters: Codable, Hashable {
            public var gender: Double?
            public var articulation: Double?
            public var assertiveness: Double?
            public var buoyancy: Double?
            public var confidence: Double?
            public var enthusiasm: Double?
            public var nasality: Double?
            public var relaxedness: Double?
            public var smoothness: Double?
            public var tepidity: Double?
            public var tightness: Double?
        }
        
        public init(
            id: String,
            name: String,
            baseVoice: String,
            parameterModel: String,
            parameters: Parameters?,
            createdOn: Int64,
            modifiedOn: Int64
        ) {
            self.id = id
            self.name = name
            self.baseVoice = baseVoice
            self.parameterModel = parameterModel
            self.parameters = parameters
            self.createdOn = createdOn
            self.modifiedOn = modifiedOn
        }
    }
}
