//
//  HumeAI.Dataset.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct Dataset: Codable {
        public let id: String
        public let name: String
        public let description: String?
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let versions: [DatasetVersion]?
        
        public struct DatasetVersion: Codable {
            public let id: String
            public let datasetId: String
            public let description: String?
            public let createdOn: Int64
            public let modifiedOn: Int64
            public let files: [HumeAI.File]?
        }
    }
}
