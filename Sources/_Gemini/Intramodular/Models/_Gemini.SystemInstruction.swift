//
//  _Gemini.SystemInstruction.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Foundation

extension _Gemini {
    public struct SystemInstruction: Codable {
        public let role: String?
        public let parts: [APISpecification.RequestBodies.Content.Part]
        
        public init(role: String? = nil, parts: [APISpecification.RequestBodies.Content.Part]) {
            self.role = role
            self.parts = parts
        }
    }
}
