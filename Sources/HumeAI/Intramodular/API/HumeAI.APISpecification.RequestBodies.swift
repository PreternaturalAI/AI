//
//  HumeAI.APISpecification.RequestBodies.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.APISpecification {
    enum RequestBodies {
        struct ListVoicesInput: Codable {
            let pageNumber: Int?
            let pageSize: Int?
            let name: String?
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case name
            }
        }
        
        struct CreateVoiceInput: Codable {
            let name: String
            let baseVoice: String
            let parameterModel: String
            let parameters: Parameters?
            
            private enum CodingKeys: String, CodingKey {
                case name
                case baseVoice = "base_voice"
                case parameterModel = "parameter_model"
                case parameters
            }
            
            struct Parameters: Codable {
                let gender: Double?
                let articulation: Double?
                let assertiveness: Double?
                let buoyancy: Double?
                let confidence: Double?
                let enthusiasm: Double?
                let nasality: Double?
                let relaxedness: Double?
                let smoothness: Double?
                let tepidity: Double?
                let tightness: Double?
            }
        }
        
        struct UpdateVoiceNameInput: Codable {
            let name: String
        }
        
        struct TTSInput: Codable {
            let text: String
            let voiceId: String
            let speed: Double?
            let stability: Double?
            let similarityBoost: Double?
            let styleExaggeration: Double?
            
            private enum CodingKeys: String, CodingKey {
                case text
                case voiceId = "voice_id"
                case speed
                case stability
                case similarityBoost = "similarity_boost"
                case styleExaggeration = "style_exaggeration"
            }
        }
    }
}
