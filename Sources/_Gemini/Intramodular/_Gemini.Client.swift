//
//  _Gemini.CLient.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import CorePersistence
import Diagnostics
import NetworkKit
import Foundation
import SwiftAPI
import Merge
import FoundationX
import Swallow

extension _Gemini {
    @RuntimeDiscoverable
    public final class Client: HTTPClient, _StaticSwift.Namespace {
        public typealias API = _Gemini.APISpecification
        public typealias Session = HTTPSession
        
        public let interface: API
        public let session: Session
        public var sessionCache: EmptyKeyedCache<Session.Request, Session.Request.Response>
        
        public required init(configuration: API.Configuration) {
            self.interface = API(configuration: configuration)
            self.session = HTTPSession.shared
            self.sessionCache = .init()
        }
        
        public convenience init(apiKey: String?) {
            self.init(configuration: .init(apiKey: apiKey))
        }
    }
}

extension _Gemini.Client {
    public func generateContent(
        with body: _Gemini.APISpecification.RequestBodies.SpeechRequest
    ) async throws -> _Gemini.APISpecification.ResponseBodies.GenerateContent {
        let input = _Gemini.APISpecification.RequestBodies.GenerateContentInput(
            model: "gemini-pro",
            requestBody: body
        )
        
        return try await run(\.generateContent, with: input)
    }
    
    public func uploadFile(
        fileData: Data,
        mimeType: String
    ) async throws -> _Gemini.File {
        let input = _Gemini.APISpecification.RequestBodies.FileUploadInput(
            fileData: fileData,
            mimeType: mimeType
        )
        
        let response = try await run(\.uploadFile, with: input)
        return response.file
    }
    
    public func deleteFile(
        fileURL: URL
    ) async throws {
        let input = _Gemini.APISpecification.RequestBodies.DeleteFileInput(fileURL: fileURL)
        try await run(\.deleteFile, with: input)
    }
}
