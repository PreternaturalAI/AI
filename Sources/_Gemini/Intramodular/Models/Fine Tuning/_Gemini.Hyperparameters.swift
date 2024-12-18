//
//  _Gemini.Hyperparameters.swift
//  AI
//
//  Created by Jared Davidson on 12/18/24.
//


extension _Gemini {
    public struct Hyperparameters: Codable {
        public let batchSize: Int
        public let learningRate: Double
        public let epochCount: Int
        
        private enum CodingKeys: String, CodingKey {
            case batchSize = "batch_size"
            case learningRate = "learning_rate"
            case epochCount = "epoch_count"
        }
        
        public init(
            batchSize: Int = 2,
            learningRate: Double = 0.001,
            epochCount: Int = 5
        ) {
            self.batchSize = batchSize
            self.learningRate = learningRate
            self.epochCount = epochCount
        }
    }
}
