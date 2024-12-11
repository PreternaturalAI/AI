//
//  Untitled.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Testing
@testable import AI

@Suite struct GeminiTests {
    @Test func testGenerateContent() async throws {
        let client = _Gemini.Client(apiKey: "test-api-key")
        
        let content = _Gemini.APISpecification.RequestBodies.Content(
            role: "user",
            parts: [.text("What is the weather like?")]
        )
        
        let request = _Gemini.APISpecification.RequestBodies.SpeechRequest(
            contents: [content],
            generationConfig: .init(
                temperature: 0.7,
                maxTokens: 100
            )
        )
        
        do {
            let _ = try await client.generateContent(with: request)
            #expect(true) // If we get here, request was properly formed
        } catch {
            #expect(false, "Generate content request failed: \(error)")
        }
    }
    
    @Test func testFileUpload() async throws {
        let client = _Gemini.Client(apiKey: "test-api-key")
        let testData = "test file content".data(using: .utf8)!
        
        do {
            let _ = try await client.uploadFile(
                fileData: testData,
                mimeType: "text/plain"
            )
            #expect(true) // If we get here, request was properly formed
        } catch {
            #expect(false, "File upload failed: \(error)")
        }
    }
    
    @Test func testFileDelete() async throws {
        let client = _Gemini.Client(apiKey: "test-api-key")
        let testURL = URL(string: "https://generativelanguage.googleapis.com/v1beta/files/test")!
        
        do {
            try await client.deleteFile(fileURL: testURL)
            #expect(true) // If we get here, request was properly formed
        } catch {
            #expect(false, "File delete failed: \(error)")
        }
    }
}
