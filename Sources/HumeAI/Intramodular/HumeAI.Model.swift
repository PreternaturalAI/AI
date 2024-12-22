//
//  HumeAI.Model.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import CoreMI
import CorePersistence
import Foundation
import Swift

extension HumeAI {
    static let parameterModel = "20241004-11parameter"
}

extension HumeAI {
    public struct APIModel: Codable {
        public var face: Face?
        public var burst: [String: String]?
        public var prosody: Prosody?
        public var language: Language?
        public var ner: NER?
        public var facemesh: [String: String]?
        
        public struct Face: Codable {
            public var fpsPred: Double?
            public var probThreshold: Double?
            public var identifyFaces: Bool?
            public var minFaceSize: UInt64?
            public var facs: [String: String]?
            public var descriptions: [String: String]?
            public var saveFaces: Bool?
            
            public init(
                fpsPred: Double? = 3.0,
                probThreshold: Double? = 0.99,
                identifyFaces: Bool? = false,
                minFaceSize: UInt64? = nil,
                facs: [String: String]? = nil,
                descriptions: [String: String]? = nil,
                saveFaces: Bool? = false
            ) {
                self.fpsPred = fpsPred
                self.probThreshold = probThreshold
                self.identifyFaces = identifyFaces
                self.minFaceSize = minFaceSize
                self.facs = facs
                self.descriptions = descriptions
                self.saveFaces = saveFaces
            }
            
            enum CodingKeys: String, CodingKey {
                case fpsPred = "fps_pred"
                case probThreshold = "prob_threshold"
                case identifyFaces = "identify_faces"
                case minFaceSize = "min_face_size"
                case facs
                case descriptions
                case saveFaces = "save_faces"
            }
        }
        
        public struct Prosody: Codable {
            public enum Granularity: String, Codable {
                case word
                case sentence
                case utterance
                case conversationalTurn = "conversational_turn"
            }
            
            public struct Window: Codable {
                public var length: Double?
                public var step: Double?
                
                public init(length: Double? = 4.0, step: Double? = 1.0) {
                    self.length = length
                    self.step = step
                }
            }
            
            public var granularity: Granularity?
            public var window: Window?
            public var identifySpeakers: Bool?
            
            public init(
                granularity: Granularity? = nil,
                window: Window? = nil,
                identifySpeakers: Bool? = false
            ) {
                self.granularity = granularity
                self.window = window
                self.identifySpeakers = identifySpeakers
            }
            
            enum CodingKeys: String, CodingKey {
                case granularity
                case window
                case identifySpeakers = "identify_speakers"
            }
        }
        
        public struct Language: Codable { }
        
        public struct NER: Codable { }
        
        public init(
            face: Face? = nil,
            burst: [String: String]? = nil,
            prosody: Prosody? = nil,
            language: Language? = nil,
            ner: NER? = nil,
            facemesh: [String: String]? = nil
        ) {
            self.face = face
            self.burst = burst
            self.prosody = prosody
            self.language = language
            self.ner = ner
            self.facemesh = facemesh
        }
    }
}

// Helper initializers for simpler model creation
extension HumeAI.APIModel {
    public static func face(
        fpsPred: Double? = 3.0,
        probThreshold: Double? = 0.99,
        identifyFaces: Bool? = false,
        minFaceSize: UInt64? = nil,
        facs: [String: String]? = [:],
        descriptions: [String: String]? = [:],
        saveFaces: Bool? = false
    ) -> Self {
        .init(face: .init(
            fpsPred: fpsPred,
            probThreshold: probThreshold,
            identifyFaces: identifyFaces,
            minFaceSize: minFaceSize,
            facs: facs,
            descriptions: descriptions,
            saveFaces: saveFaces
        ))
    }
    
    public static func burst() -> Self {
        .init(burst: [:])
    }
    
    public static func prosody(
        granularity: Prosody.Granularity? = nil,
        windowLength: Double? = 4.0,
        windowStep: Double? = 1.0,
        identifySpeakers: Bool? = false
    ) -> Self {
        .init(prosody: .init(
            granularity: granularity,
            window: .init(length: windowLength, step: windowStep),
            identifySpeakers: identifySpeakers
        ))
    }
    
    public static func language() -> Self {
        .init(language: .init())
    }
    
    public static func ner() -> Self {
        .init(ner: .init())
    }
    
    public static func facemesh() -> Self {
        .init(facemesh: [:])
    }
}
