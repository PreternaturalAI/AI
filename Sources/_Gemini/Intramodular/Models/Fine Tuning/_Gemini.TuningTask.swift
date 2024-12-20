//
//  _Gemini.TuningTask.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//

import Foundation

extension _Gemini {
    public struct TuningTask: Codable {
        public let hyperparameters: Hyperparameters
        public let trainingData: TrainingData
        
        public init(
            hyperparameters: Hyperparameters,
            trainingData: TrainingData
        ) {
            self.hyperparameters = hyperparameters
            self.trainingData = trainingData
        }
    }
}
