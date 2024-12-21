//
// Copyright (c) Preternatural AI, Inc.
//

extension NeetsAI.APISpecification {
    enum RequestBodies {
        struct TTSInput: Codable {
            let params: TTSParams
            let text: String
            let voiceId: String
            
            struct TTSParams: Codable {
                let model: String
                let temperature: Double
                let diffusionIterations: Int
                
                private enum CodingKeys: String, CodingKey {
                    case model
                    case temperature
                    case diffusionIterations = "diffusion_iterations"
                }
            }
            
            private enum CodingKeys: String, CodingKey {
                case params
                case text
                case voiceId = "voice_id"
            }
        }
        
        struct ChatInput: Codable {
            let messages: [NeetsAI.ChatMessage]
            let model: String
        }
    }
}

