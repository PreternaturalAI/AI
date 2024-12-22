//
// Copyright (c) Preternatural AI, Inc.
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
