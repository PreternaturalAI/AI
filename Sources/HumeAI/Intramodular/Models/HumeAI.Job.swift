//
// Copyright (c) Preternatural AI, Inc.
//

extension HumeAI {
    // MARK: - Root Response
    public struct Job: Codable {
        public let state: JobState
        public let userID: String
        public let type: String
        public let jobID: String
        public let request: JobRequest
        
        enum CodingKeys: String, CodingKey {
            case state
            case userID = "userId"
            case type
            case jobID = "jobId"
            case request
        }
    }
    
    // MARK: - Job State
    public struct JobState: Codable {
        public let endedTimestampMs: Int64
        public let createdTimestampMs: Int64
        public let numPredictions: Int
        public let status: String
        public let numErrors: Int
        public let startedTimestampMs: Int64
    }
    
    // MARK: - Job Request
    public struct JobRequest: Codable {
        public let models: Models
        public let notify: Bool
        public let urls: [String]
        public let callbackUrl: String?
        public let text: [String]
        public let files: [String]
        public let registryFiles: [String]
    }
    
    // MARK: - Models
    public struct Models: Codable {
        public let burst: [String: [String: String]]?
        public let facemesh: JSON?
        public let language: JSON?
        public let face: JSON?
        public let ner: JSON?
        public let prosody: JSON?
        
        public enum JSON: Codable {
            case null
            case bool(Bool)
            case number(Double)
            case string(String)
            case array([JSON])
            case object([String: JSON])
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.singleValueContainer()
                if container.decodeNil() {
                    self = .null
                } else if let bool = try? container.decode(Bool.self) {
                    self = .bool(bool)
                } else if let number = try? container.decode(Double.self) {
                    self = .number(number)
                } else if let string = try? container.decode(String.self) {
                    self = .string(string)
                } else if let array = try? container.decode([JSON].self) {
                    self = .array(array)
                } else if let object = try? container.decode([String: JSON].self) {
                    self = .object(object)
                } else {
                    throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid JSON value")
                }
            }
            
            public func encode(to encoder: Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                    case .null:
                        try container.encodeNil()
                    case .bool(let bool):
                        try container.encode(bool)
                    case .number(let number):
                        try container.encode(number)
                    case .string(let string):
                        try container.encode(string)
                    case .array(let array):
                        try container.encode(array)
                    case .object(let object):
                        try container.encode(object)
                }
            }
        }
    }
    
    public struct JobID: Codable {
        public let jobID: String
        
        enum CodingKeys: String, CodingKey {
            case jobID = "jobId"
        }
    }
}
