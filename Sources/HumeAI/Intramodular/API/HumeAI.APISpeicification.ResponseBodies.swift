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
    }
}
