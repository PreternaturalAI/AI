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
        
        struct BatchInferenceJobInput: Codable {
            let files: [FileInput]
            let models: [HumeAI.Model]
            let callback: CallbackConfig?
        }
        
        struct FileInput: Codable {
            let url: String
            let mimeType: String
            let metadata: [String: String]?
            
            private enum CodingKeys: String, CodingKey {
                case url
                case mimeType = "mime_type"
                case metadata
            }
        }
        
        struct CallbackConfig: Codable {
            let url: String
            let metadata: [String: String]?
        }
        
        struct ChatRequest: Codable {
            let messages: [Message]
            let model: String
            let temperature: Double?
            let maxTokens: Int?
            let stream: Bool?
            
            struct Message: Codable {
                let role: String
                let content: String
            }
            
            private enum CodingKeys: String, CodingKey {
                case messages, model, temperature
                case maxTokens = "max_tokens"
                case stream
            }
        }
        
        struct CreateConfigInput: Codable {
            let name: String
            let description: String?
            let settings: [String: String]
        }
        
        struct UpdateConfigNameInput: Codable {
            let name: String
        }
        
        struct UpdateConfigDescriptionInput: Codable {
            let description: String
        }
        
        struct CreateDatasetInput: Codable {
            let name: String
            let description: String?
            let fileIds: [String]
            
            private enum CodingKeys: String, CodingKey {
                case name, description
                case fileIds = "file_ids"
            }
        }
        
        struct UploadFileInput: Codable, HTTPRequest.Multipart.ContentConvertible {
            let file: Data
            let name: String
            let metadata: [String: String]?
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result: HTTPRequest.Multipart.Content = .init()
                result.append(
                    .file(
                        named: "file",
                        data: file,
                        filename: name,
                        contentType: .json
                    )
                )
                if let metadata = metadata {
                    result.append(
                        .string(
                            named: "metadata",
                            value: try JSONEncoder().encode(metadata).utf8String ?? ""
                        )
                    )
                }
                return result
            }
        }
        
        struct UpdateFileNameInput: Codable {
            let name: String
        }
        
        struct TrainingJobInput: Codable {
            let datasetId: String
            let name: String
            let description: String?
            let configuration: [String: String]
            
            private enum CodingKeys: String, CodingKey {
                case datasetId = "dataset_id"
                case name, description, configuration
            }
        }
        
        struct CustomInferenceJobInput: Codable {
            let modelId: String
            let files: [FileInput]
            let configuration: [String: String]
            
            private enum CodingKeys: String, CodingKey {
                case modelId = "model_id"
                case files, configuration
            }
        }
        
        struct UpdateModelNameInput: Codable {
            let name: String
        }
        
        struct UpdateModelDescriptionInput: Codable {
            let description: String
        }
        
        struct CreatePromptInput: Codable {
            let name: String
            let description: String?
            let content: String
            let metadata: [String: String]?
        }
        
        struct UpdatePromptNameInput: Codable {
            let name: String
        }
        
        struct UpdatePromptDescriptionInput: Codable {
            let description: String
        }
        
        struct StreamInput: Codable, HTTPRequest.Multipart.ContentConvertible {
            let file: Data
            let models: [HumeAI.Model]
            let metadata: [String: String]?
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result: HTTPRequest.Multipart.Content = .init()
                
                result.append(
                    .file(
                        named: "file",
                        data: file,
                        filename: "file",
                        contentType: .binary
                    )
                )
                result.append(
                    .string(
                        named: "models",
                        value: try JSONEncoder().encode(models).utf8String ?? ""
                    )
                )
                
                if let metadata = metadata {
                    result.append(
                        .string(
                            named: "metadata",
                            value: try JSONEncoder().encode(metadata).utf8String ?? ""
                        )
                    )
                }
                
                return result
            }
        }
        
        struct CreateToolInput: Codable {
            let name: String
            let description: String?
            let configuration: Configuration
            
            struct Configuration: Codable {
                let parameters: [String: String]
            }
        }
        
        struct UpdateToolNameInput: Codable {
            let name: String
        }
        
        struct UpdateToolDescriptionInput: Codable {
            let description: String
        }
    }
}
