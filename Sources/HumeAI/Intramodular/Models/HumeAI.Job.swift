//
//  HumeAI.Job.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

extension HumeAI {
    public struct Job {
        public let id: String
        public let status: String
        public let createdOn: Int64
        public let modifiedOn: Int64
        public let predictions: [Prediction]?
        public let artifacts: [String: String]?
        
        public struct Prediction {
            public let file: FileInfo
            public let results: [ModelResult]
            
            public struct FileInfo {
                public let url: String
                public let mimeType: String
                public let metadata: [String: String]?
            }
            
            public struct ModelResult {
                public let model: String
                public let results: [String: String]
            }
        }
    }
}
