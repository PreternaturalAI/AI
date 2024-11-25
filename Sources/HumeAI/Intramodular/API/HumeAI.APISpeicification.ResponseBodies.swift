//
//  HumeAI.APISpeicification.ResponseBodies.swift
//  AI
//
//  Created by Jared Davidson on 11/22/24.
//

import NetworkKit
import SwiftAPI
import Merge

extension HumeAI.APISpecification {
    enum ResponseBodies {
        struct VoiceList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let voices: [HumeAI.Voice]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case voices = "custom_voices_page"
            }
        }
        
        typealias Voice = HumeAI.Voice
        
        struct TTSOutput: Codable {
            public let audio: Data
            public let durationMs: Int
            
            private enum CodingKeys: String, CodingKey {
                case audio
                case durationMs = "duration_ms"
            }
            
            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                let base64String = try container.decode(String.self, forKey: .audio)
                self.audio = try Data(base64Encoded: base64String).unwrap()
                self.durationMs = try container.decode(Int.self, forKey: .durationMs)
            }
        }
        
        struct TTSStreamOutput: Codable {
            public let streamURL: URL
            public let durationMs: Int
            
            private enum CodingKeys: String, CodingKey {
                case streamURL = "stream_url"
                case durationMs = "duration_ms"
            }
        }
        
        struct ChatResponse: Codable {
            let id: String
            let created: Int64
            let choices: [Choice]
            let usage: Usage
            
            struct Choice: Codable {
                let index: Int
                let message: Message
                let finishReason: String?
                
                struct Message: Codable {
                    let role: String
                    let content: String
                }
                
                private enum CodingKeys: String, CodingKey {
                    case index, message
                    case finishReason = "finish_reason"
                }
            }
            
            struct Usage: Codable {
                let promptTokens: Int
                let completionTokens: Int
                let totalTokens: Int
                
                private enum CodingKeys: String, CodingKey {
                    case promptTokens = "prompt_tokens"
                    case completionTokens = "completion_tokens"
                    case totalTokens = "total_tokens"
                }
            }
        }
        
        struct ChatGroup: Codable {
            let id: String
            let name: String
            let createdOn: Int64
            let modifiedOn: Int64
            let chats: [Chat]?
        }
        
        struct ChatGroupList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let chatGroups: [ChatGroup]
        }
        
        struct Chat: Codable {
            let id: String
            let name: String
            let createdOn: Int64
            let modifiedOn: Int64
        }
        
        struct ChatEvent: Codable {
            let id: String
            let chatId: String
            let type: String
            let content: String
            let createdOn: Int64
            let audioUrl: String?
            let metadata: [String: String]?
        }
        
        struct ChatList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let chats: [HumeAI.Chat]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case chats = "chats_page"
            }
        }
        
        struct ChatEventList: Codable {
            let events: [HumeAI.ChatEvent]
        }
        
        typealias ChatAudio = Data
        
        struct ConfigVersion: Codable {
            let id: String
            let configId: String
            let description: String?
            let createdOn: Int64
            let modifiedOn: Int64
            let settings: [String: String]
        }
        
        struct ConfigList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let configs: [HumeAI.Config]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case configs = "configs_page"
            }
        }
        
        struct VoiceParameters: Codable {
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
        
        struct CustomVoiceList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let voices: [Voice]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case voices = "voices_page"
            }
        }
        
        struct DatasetList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let datasets: [HumeAI.Dataset]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case datasets = "datasets_page"
            }
        }
        
        struct FileList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let files: [HumeAI.File]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case files = "files_page"
            }
        }
        
        struct ModelVersion: Codable {
            let id: String
            let modelId: String
            let description: String?
            let createdOn: Int64
            let modifiedOn: Int64
            let configuration: [String: String]
        }
        
        struct Model: Codable {
            let id: String
            let name: String
            let description: String?
            let createdOn: Int64
            let modifiedOn: Int64
            let versions: [ModelVersion]?
        }
        
        struct ModelList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let models: [HumeAI.Model]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case models = "models_page"
            }
        }
        
        struct PromptList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let prompts: [HumeAI.Prompt]
            
            private enum CodingKeys: String, CodingKey {
                case pageNumber = "page_number"
                case pageSize = "page_size"
                case totalPages = "total_pages"
                case prompts = "prompts_page"
            }
        }
        
        struct ToolVersionList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let toolsPage: [HumeAI.Tool.ToolVersion]
        }
        
        struct ToolList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let toolsPage: [HumeAI.Tool]
        }
       
        struct JobList: Codable {
            let pageNumber: Int
            let pageSize: Int
            let totalPages: Int
            let jobs: [HumeAI.Job]
        }
    }
}
