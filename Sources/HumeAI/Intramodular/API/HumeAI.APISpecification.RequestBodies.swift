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
        }
        
        struct CreateVoiceInput: Codable {
            let name: String
            let baseVoice: String
            let parameterModel: String
            let parameters: HumeAI.Voice.Parameters?
        }
        
        struct CreateVoiceVersionInput: Codable {
            let id: String
            let baseVoice: String
            let parameterModel: String
            let parameters: HumeAI.Voice.Parameters?
        }
        
        struct UpdateVoiceNameInput: Codable {
            let id: String
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
            let urls: [URL]
            let models: HumeAI.APIModel
            let callback: CallbackConfig?
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
        
        struct CreateConfigVersionInput: Codable {
            let id: String
            let version: Int
            let description: String?
            let settings: [String: String]
        }
        
        struct UpdateConfigNameInput: Codable {
            let id: String
            let name: String
        }
        
        struct UpdateConfigDescriptionInput: Codable {
            let id: String
            let versionID: String
            let description: String
        }
        
        struct CreateDatasetInput: Codable {
            let name: String
            let description: String?
            let fileIds: [String]
        }
        
        struct CreateDatasetVersionInput: Codable {
            let id: String
            let version: Int
            let description: String?
            let fileIds: [String]
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
                            value: try JSONEncoder().encode(metadata).toUTF8String() ?? ""
                        )
                    )
                }
                return result
            }
        }
        
        struct UpdateFileNameInput: Codable {
            let id: String
            let name: String
        }
        
        struct TrainingJobInput: Codable {
            let datasetId: String
            let name: String
            let description: String?
            let configuration: [String: String]
        }
        
        struct CustomInferenceJobInput: Codable {
            let modelId: String
            let files: [HumeAI.FileInput]
            let configuration: [String: String]
        }
        
        struct UpdateModelNameInput: Codable {
            let id: String
            let name: String
        }
        
        struct UpdateModelDescriptionInput: Codable {
            let id: String
            let versionId: String
            let description: String
        }
        
        struct CreatePromptInput: Codable {
            let name: String
            let text: String
            let versionDescription: String?
        }
        
        struct CreatePromptVersionInput: Codable {
            let id: String
            let text: String
            let versionDescription: String?
        }
        
        struct UpdatePromptNameInput: Codable {
            let id: String
            let name: String
        }
        
        struct UpdatePromptDescriptionInput: Codable {
            let id: String
            let version: Int
            let description: String
        }
        
        struct StreamInput: Codable, HTTPRequest.Multipart.ContentConvertible {
            let id: String  // Add file ID
            let file: Data
            let models: [HumeAI.APIModel]
            let metadata: [String: String]?
            
            public func __conversion() throws -> HTTPRequest.Multipart.Content {
                var result: HTTPRequest.Multipart.Content = .init()
                
                result.append(
                    .file(
                        named: "file",
                        data: file,
                        filename: "file",
                        contentType: .json
                    )
                )
                result.append(
                    .string(
                        named: "models",
                        value: try JSONEncoder().encode(models).toUTF8String() ?? ""
                    )
                )
                
                if let metadata = metadata {
                    result.append(
                        .string(
                            named: "metadata",
                            value: try JSONEncoder().encode(metadata).toUTF8String() ?? ""
                        )
                    )
                }
                
                return result
            }
        }
        
        struct CreateToolInput: Codable {
            var id: String? = nil
            let name: String
            let parameters: String
            let versionDescription: String?
            let description: String?
            let fallbackContent: String?
        }
        
        struct CreateToolVersionInput: Codable {
            let id: String
            let description: String?
            let configuration: Configuration
            
            struct Configuration: Codable {
                let parameters: [String: String]
            }
        }
        
        struct UpdateToolNameInput: Codable {
            let id: String
            let name: String
        }
        
        struct UpdateToolDescriptionInput: Codable {
            let id: String
            let version: Int
            let description: String
        }
    }
}
