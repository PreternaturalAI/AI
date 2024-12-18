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
    
    public struct TrainingData: Codable {
        public let examples: Examples
        
        public init(examples: Examples) {
            self.examples = examples
        }
    }
    
    public struct Examples: Codable {
        public let examples: [Example]
        
        public init(examples: [Example]) {
            self.examples = examples
        }
    }
    
    public struct Example: Codable {
        public let textInput: String
        public let output: String
        
        private enum CodingKeys: String, CodingKey {
            case textInput = "text_input"
            case output
        }
        
        public init(textInput: String, output: String) {
            self.textInput = textInput
            self.output = output
        }
    }
    
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
