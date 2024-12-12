//
//  Untitled.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Testing
import Foundation
import _Gemini

@Suite struct GeminiTests {
    func loadTestFile(named filename: String) throws -> Data {
        #warning("FIX ME")
        let baseDirectory = "/Users/jareddavidson/Documents/Preternatural/AI"
        let testFilesPath = "\(baseDirectory)/Tests/_Gemini/Intramodular/TestFiles"
        let fileURL = URL(fileURLWithPath: testFilesPath)
            .appendingPathComponent(filename)
        
        print("Attempting to load file from: \(fileURL.path)")
        
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw NSError(
                domain: "TestError",
                code: 1,
                userInfo: [
                    NSLocalizedDescriptionKey: "File not found at path: \(fileURL.path)"
                ]
            )
        }
        
        return try Data(contentsOf: fileURL)
    }
    
        @Test func testVideoContentGeneration() async throws {
            do {
                let videoData = try loadTestFile(named: "LintMySwiftSmall.mov")
                print("Successfully loaded video data: \(videoData.count) bytes")
    
                let response = try await client.generateContent(
                    data: videoData,
                    type: .custom("video/quicktime"),
                    prompt: "What is happening in this video?"
                )
    
                #expect(response.candidates != nil)
                #expect(!response.candidates!.isEmpty)
    
                if let textContent = response.candidates?.first?.content?.parts?.first {
                    print("Response: \(textContent)")
                }
            } catch {
                print("Detailed error: \(String(describing: error))")
                #expect(false, "Video content generation failed: \(error)")
            }
        }
    
    
    @Test func testAudioContentGeneration() async throws {
        do {
            let audioData = try loadTestFile(named: "LintMySwift2.m4a")
            
            let response = try await client.generateContent(
                data: audioData,
                type: .custom("audio/x-m4a"),
                prompt: "What is being said in this audio?"
            )
            
            #expect(response.candidates != nil)
            #expect(!response.candidates!.isEmpty)
        } catch {
            #expect(false, "Audio content generation failed: \(error)")
        }
    }
    
    @Test func testFileUpload() async throws {
        do {
            let _ = try await createFile(string: "Test")
            #expect(true)
        } catch {
            #expect(false, "File upload failed: \(error)")
        }
    }
    
    @Test func testGetFile() async throws {
        do {
            let file = try await createFile(string: "Test")
            let _ = try await client.getFile(name: file.name ?? "")
            #expect(true)
        } catch {
            #expect(false, "File upload failed: \(error)")
        }
    }
    
    @Test func testFileDelete() async throws {
        do {
            let file = try await createFile(string: "Test")
            try await client.deleteFile(fileURL: file.uri)
            #expect(true)
        } catch {
            #expect(false, "File delete failed: \(error)")
        }
    }
    
    
    func createFile(string: String) async throws -> _Gemini.File {
        return try await client.uploadFile(
            fileData: string.data(using: .utf8)!,
            mimeType: "text/plain",
            displayName: "Hello World"
        )
    }
}
