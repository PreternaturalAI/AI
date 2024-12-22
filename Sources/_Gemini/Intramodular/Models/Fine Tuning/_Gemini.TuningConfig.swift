//
//  _Gemini.TuningConfig.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Foundation

extension _Gemini {
    public struct TuningConfig: Codable {
        public let displayName: String
        public let baseModel: String
        public let tuningTask: TuningTask
        
        public init(
            displayName: String,
            baseModel: _Gemini.Model,
            tuningTask: TuningTask
        ) {
            self.displayName = displayName
            self.baseModel = "models/" + baseModel.rawValue + "-001-tuning"
            self.tuningTask = tuningTask
        }
    }
}
