//
//  _Gemini.TuningModel.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

// FIXME: - Break Apart

extension _Gemini {
    public struct TunedModel: Codable {
        public let name: String
        public let displayName: String
        public let baseModel: String
        public let state: State
        public let createTime: String
        public let updateTime: String
        
        public enum State: String, Codable {
            case stateUnspecified = "STATE_UNSPECIFIED"
            case creating = "CREATING"
            case active = "ACTIVE"
            case failed = "FAILED"
        }
    }
}
