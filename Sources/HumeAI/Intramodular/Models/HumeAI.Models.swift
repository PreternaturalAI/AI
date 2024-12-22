//
//  HumeAI.Models.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct Model: Codable {
        public let id: String
        public let name: String
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let totalStars: Int64
        public let modelIsStarredByUser: Bool
        public let archived: Bool
        public let isPubliclyShared: Bool
        public let latestVersion: ModelVersion?
        
        public struct ModelVersion: Codable {
            public let id: String
            public let modelId: String
            public let userId: String
            public let version: String
            public let sourceUri: String
            public let datasetVersionId: String
            public let createdOn: Int64
            public let metadata: [String: MetadataValue]?
            public let description: String?
            public let tags: [Tag]?
            public let fileType: String?
            public let targetFeature: String?
            public let taskType: String?
            public let trainingJobId: String?
            
            public struct Tag: Codable {
                public let key: String
                public let value: String
            }
            
            public enum MetadataValue: Codable {
                case string(String)
                case object([String: String])
                
                public init(from decoder: Decoder) throws {
                    let container = try decoder.singleValueContainer()
                    if let stringValue = try? container.decode(String.self) {
                        self = .string(stringValue)
                    } else if let objectValue = try? container.decode([String: String].self) {
                        self = .object(objectValue)
                    } else {
                        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid metadata value")
                    }
                }
                
                public func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .string(let value):
                        try container.encode(value)
                    case .object(let value):
                        try container.encode(value)
                    }
                }
            }
        }
    }
    
    public struct ModelList: Codable {
        public let content: [Model]
        public let pageable: PageInfo
        public let total: Int64
        public let last: Bool
        public let totalElements: Int64
        public let totalPages: Int
        public let size: Int
        public let number: Int
        public let sort: SortInfo
        public let first: Bool
        public let numberOfElements: Int
        public let empty: Bool
        
        public struct PageInfo: Codable {
            public let offset: Int64
            public let sort: SortInfo
            public let paged: Bool
            public let unpaged: Bool
            public let pageNumber: Int
            public let pageSize: Int
        }
        
        public struct SortInfo: Codable {
            public let empty: Bool
            public let sorted: Bool
            public let unsorted: Bool
        }
    }
}
