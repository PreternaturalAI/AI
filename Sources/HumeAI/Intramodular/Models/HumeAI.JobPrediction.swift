//
//  HumeAI.JobPrediction.swift
//  AI
//
//  Created by Jared Davidson on 11/25/24.
//

import Foundation

extension HumeAI {
    public struct JobPrediction: Codable {
        public let source: Source
        public let results: Results
        
        public struct Source: Codable {
            public let type: String
            public let url: String
        }
        
        public struct Results: Codable {
            public let predictions: [Prediction]
            public let errors: [String]
        }
        
        public struct Prediction: Codable {
            public let file: String
            public let models: Models
        }
        
        public struct Models: Codable {
            public let face: FaceModel?
            
            public struct FaceModel: Codable {
                public let groupedPredictions: [GroupedPrediction]
                
                enum CodingKeys: String, CodingKey {
                    case groupedPredictions = "grouped_predictions"
                }
            }
        }
        
        public struct GroupedPrediction: Codable {
            public let id: String
            public let predictions: [FacePrediction]
        }
        
        public struct FacePrediction: Codable {
            public let frame: Int
            public let time: Int
            public let prob: Double
            public let box: BoundingBox
            public let emotions: [Emotion]
        }
        
        public struct BoundingBox: Codable {
            public let x: Double
            public let y: Double
            public let w: Double
            public let h: Double
        }
        
        public struct Emotion: Codable {
            public let name: String
            public let score: Double
        }
    }
}
