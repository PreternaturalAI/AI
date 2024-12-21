//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import NetworkKit
import Swift

extension OpenAI {
    public struct FineTuning  {
        
    }
}

extension OpenAI.FineTuning {
    public struct Jobs: Codable {
        public enum CodingKeys: String, CodingKey {
            case object
            case jobs = "data"
            case hasMore
        }
        
        public let object: String
        public let jobs: [Job]
        public let hasMore: Bool
    }
}

extension OpenAI.FineTuning {
    public struct Job: Codable, Identifiable {
        public typealias ID = _TypeAssociatedID<OpenAI.FineTuning.Job, String>
        
        public enum CodingKeys: String, CodingKey {
            case id
            case createdAt
            case error
            case fineTunedModel
            case finishedAt
            case hyperparameters
            case model
            case object
            case organizationID = "organizationId"
            case resultFiles
            case status
            case trainedTokens
            case trainingFileID = "trainingFile"
            case validationFileID = "validationFile"
            case integrations
            case seed
            case estimatedFinish = "estimatedFinish"
            case suffix = "userProvidedSuffix"
        }
        /// The object identifier, which can be referenced in the API endpoints.
        public let id: ID
        /// The Unix timestamp (in seconds) for when the fine-tuning job was created.
        public let createdAt: Int
        /// For fine-tuning jobs that have failed, this will contain more information on the cause of the failure.
        public let error: JobFailedError?
        /// The name of the fine-tuned model that is being created. The value will be null if the fine-tuning job is still running.
        public let fineTunedModel: String?
        /// The Unix timestamp (in seconds) for when the fine-tuning job was finished. The value will be null if the fine-tuning job is still running.
        public let finishedAt: Int?
        /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset. "auto" decides the optimal number of epochs based on the size of the dataset. If setting the number manually, we support any number between 1 and 50 epochs.
        public let hyperparameters: Hyperparameters
        /// The base model that is being fine-tuned.
        public let model: OpenAI.Model.Chat
        /// The object type, which is always "fine_tuning.job".
        public let object: String
        /// The organization that owns the fine-tuning job.
        public let organizationID: String
        /// The compiled results file ID(s) for the fine-tuning job. You can retrieve the results with the Files API.
        public let resultFiles: [String]?
        /// The current status of the fine-tuning job
        public let status: Status
        /// The total number of billable tokens processed by this fine-tuning job. The value will be null if the fine-tuning job is still running.
        public let trainedTokens: Int?
        /// The file ID used for training. You can retrieve the training data with the Files API.
        public let trainingFileID: String
        /// The file ID used for validation. You can retrieve the validation results with the Files API.
        public let validationFileID: String?
        /// A list of integrations to enable for this fine-tuning job.
        public let integrations: [Integration]?
        /// The seed used for the fine-tuning job.
        public let seed: Int
        /// The Unix timestamp (in seconds) for when the fine-tuning job is estimated to finish. The value will be null if the fine-tuning job is not running.
        public let estimatedFinish: Int?
        public let suffix: String?
    }
}

extension OpenAI.FineTuning.Job {
    public struct Events: Codable {
        public enum CodingKeys: String, CodingKey {
            case object
            case events = "data"
            case hasMore
        }
        
        public let object: String
        public let events: [Event]
        public let hasMore: Bool
    }
    
    public struct Event: Codable, Identifiable {
        public typealias ID = _TypeAssociatedID<OpenAI.FineTuning.Job.Event, String>

        public let id: ID
        public let createdAt: Int
        public let level: String
        public let message: String
        public let object: String
    }
}

extension OpenAI.FineTuning.Job {
    public struct Checkpoints: Codable {
        public enum CodingKeys: String, CodingKey {
            case object
            case checkpoints = "data"
            case firstID = "firstId"
            case lastID = "lastId"
            case hasMore
        }
        
        public let object: String
        public let checkpoints: [Checkpoint]
        public let firstID: String?
        public let lastID: String?
        public let hasMore: Bool
    }
    
    /// The fine_tuning.job.checkpoint object represents a model checkpoint for a fine-tuning job that is ready to use.
    public struct Checkpoint: Codable, Identifiable {
        public typealias ID = _TypeAssociatedID<OpenAI.FineTuning.Job.Event, String>

        public enum CodingKeys: String, CodingKey {
            case id
            case createdAt
            case fineTunedModelCheckpoint
            case fineTuningJobID = "fineTuningJobId"
            case stepNumber
            case metrics
            case object
        }
        /// The checkpoint identifier, which can be referenced in the API endpoints.
        public let id: ID
        /// The Unix timestamp (in seconds) for when the checkpoint was created.
        public let createdAt: Int
        /// The name of the fine-tuned checkpoint model that is created.
        public let fineTunedModelCheckpoint: String
        /// The name of the fine-tuning job that this checkpoint was created from.
        public let fineTuningJobID: String
        /// The step number that the checkpoint was created at.
        public let stepNumber: Int
        /// Metrics at the step number during the fine-tuning job.
        public let metrics: Metrics
        /// The object type, which is always "fine_tuning.job.checkpoint".
        public let object: String
    }
}

// MARK - Auxiliary
extension OpenAI.FineTuning {
    
    /// The hyperparameters used for the fine-tuning job.
    public struct Hyperparameters: Codable {
        /// Number of examples in each batch. A larger batch size means that model parameters are updated less frequently, but with lower variance.
        public let batchSize: Option?
        /// Scaling factor for the learning rate. A smaller learning rate may be useful to avoid overfitting.
        public let learningRateMultiplier: Option?
        /// The number of epochs to train the model for. An epoch refers to one full cycle through the training dataset.
        public let nEpochs: Option?
        
        public init(
            batchSize: Option?,
            learningRateMultiplier: Option?,
            nEpochs: Option?
        ) {
            self.batchSize = batchSize
            self.learningRateMultiplier = learningRateMultiplier
            self.nEpochs = nEpochs
        }
    }
}

extension OpenAI.FineTuning {
    public struct Integration: Codable {
        public let type: String
        public let wandb: Wandb
    }
}

extension OpenAI.FineTuning.Job {
    public struct JobFailedError: Codable {
        /// A machine-readable error code.
        public let code: String?
        /// A human-readable error message.
        public let message: String?
        /// The parameter that was invalid, usually training_file or validation_file. This field will be null if the failure was not parameter-specific.
        public let param: String?
    }
    
    public enum Status: String, Codable {
        case validatingFiles = "validating_files"
        case queued
        case running
        case succeeded
        case failed
        case cancelled
    }
}

extension OpenAI.FineTuning.Hyperparameters {
    public enum Option: Codable {
        case integer(Int)
        case string(String)
        case auto
        
        public var rawValue: AnyCodable {
            switch self {
            case .integer(let value):
                return AnyCodable.number(value)
            case .string(let value):
                return AnyCodable.string(value)
            case .auto:
                return AnyCodable.string("auto")
            }
        }
        
        public init?(rawValue: AnyCodable) {
            switch rawValue {
            case .number(let number):
                if let intValue = Int(number.description) {
                    self = .integer(intValue)
                } else {
                    return nil
                }
            case .string(let stringValue):
                if stringValue.lowercased() == "auto" {
                    self = .auto
                } else {
                    self = .string(stringValue)
                }
            default:
                return nil
            }
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let intValue = try? container.decode(Int.self) {
                self = .integer(intValue)
            } else if let stringValue = try? container.decode(String.self) {
                self = stringValue.lowercased() == "auto" ? .auto : .string(stringValue)
            } else {
                throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode HyperparameterOption")
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .integer(let value):
                try container.encode(value)
            case .string(let value):
                try container.encode(value)
            case .auto:
                try container.encode("auto")
            }
        }
    }
}

extension OpenAI.FineTuning.Integration {
    public struct Wandb: Codable {
        /// The name of the project that the new run will be created under.
        public let project: String
        /// A display name to set for the run. If not set, we will use the Job ID as the name.
        public let name: String?
        /// The entity to use for the run. This allows you to set the team or username of the WandB user that you would like associated with the run. If not set, the default entity for the registered WandB API key is used.
        public let entity: String?
        /// A list of tags to be attached to the newly created run. These tags are passed through directly to WandB. Some default tags are generated by OpenAI: "openai/finetune", "openai/{base-model}", "openai/{ftjob-abcdef}".
        public let tags: [String]?
    }
}

extension OpenAI.FineTuning.Job.Checkpoint {
    public struct Metrics: Codable {
        public let step: Int
        public let trainLoss: Double?
        public let trainMeanTokenAccuracy: Double?
        public let validLoss: Double?
        public let validMeanTokenAccuracy: Double?
        public let fullValidLoss: Double?
        public let fullValidMeanTokenAccuracy: Double?
    }
}
