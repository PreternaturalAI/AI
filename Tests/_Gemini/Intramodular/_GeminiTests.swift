//
//  Untitled.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Testing
import Foundation
import _Gemini

private final class BundleHelper {}

@Suite struct GeminiTests {
    func loadTestFile(named filename: String, fileExtension: String) throws -> Data {
        let sourceFile = #file
        let packageRoot = URL(fileURLWithPath: sourceFile)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
        
        let resourcePath = packageRoot
            .appendingPathComponent("_Gemini")
            .appendingPathComponent("Intramodular")
            .appendingPathComponent("Resources")
            .appendingPathComponent("\(filename).\(fileExtension)")
        
        guard FileManager.default.fileExists(atPath: resourcePath.path) else {
            throw GeminiTestError.fileNotFound(resourcePath.path)
        }
        
        do {
            return try Data(contentsOf: resourcePath)
        } catch {
            throw GeminiTestError.fileLoadError(error)
        }
    }
    
    @Test func testVideoContentGeneration() async throws {
        do {
            let videoData = try loadTestFile(named: "LintMySwiftSmall", fileExtension: "mov")
            print("Successfully loaded video data: \(videoData.count) bytes")
            
            let response = try await client.generateContent(
                data: videoData,
                type: .custom("video/quicktime"),
                prompt: "What is happening in this video?",
                model: .gemini_1_5_flash
            )
            
            #expect(response.candidates != nil)
            #expect(!response.candidates!.isEmpty)
            
            if let textContent = response.candidates?.first?.content?.parts?.first {
                print("Response: \(textContent)")
            }
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "Video content generation failed: \(error)")
        } catch {
            throw GeminiTestError.videoProcessingError(error)
        }
    }
    
    @Test func testAudioContentGeneration() async throws {
        do {
            let audioData = try loadTestFile(named: "LintMySwift2", fileExtension: "m4a")
            
            let response = try await client.generateContent(
                data: audioData,
                type: .custom("audio/x-m4a"),
                prompt: "What is being said in this audio?",
                model: .gemini_1_5_flash
            )
            
            #expect(response.candidates != nil)
            #expect(!response.candidates!.isEmpty)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "Audio content generation failed: \(error)")
        } catch {
            throw GeminiTestError.audioProcessingError(error)
        }
    }
    
    @Test func testFileUpload() async throws {
        do {
            let _ = try await createFile(string: "Test")
            #expect(true)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "File upload failed: \(error)")
        } catch {
            throw GeminiTestError.fileUploadError(error)
        }
    }
    
    @Test func testGetFile() async throws {
        do {
            let file = try await createFile(string: "Test")
            let _ = try await client.getFile(name: file.name ?? "")
            #expect(true)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "File retrieval failed: \(error)")
        } catch {
            throw GeminiTestError.fileRetrievalError(error)
        }
    }
    
    @Test func testFileDelete() async throws {
        do {
            let file = try await createFile(string: "Test")
            try await client.deleteFile(fileURL: file.uri)
            #expect(true)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "File deletion failed: \(error)")
        } catch {
            throw GeminiTestError.fileDeleteError(error)
        }
    }
    
    func createFile(string: String) async throws -> _Gemini.File {
        do {
            let audioData = try loadTestFile(named: "LintMySwift2", fileExtension: "m4a")
            print(audioData)
            
            return try await client.uploadFile(
                fileData: audioData,
                mimeType: .custom("audio/x-m4a"),
                displayName: "Hello World"
            )
        } catch let error as GeminiTestError {
            throw error
        } catch {
            throw GeminiTestError.fileUploadError(error)
        }
    }
}
// Error Handling

fileprivate enum GeminiTestError: LocalizedError {
    case fileNotFound(String)
    case invalidFileURL(String)
    case fileLoadError(Error)
    case videoProcessingError(Error)
    case audioProcessingError(Error)
    case fileUploadError(Error)
    case fileDeleteError(Error)
    case fileRetrievalError(Error)
    
    var errorDescription: String? {
        switch self {
            case .fileNotFound(let path):
                return "File not found at path: \(path)"
            case .invalidFileURL(let filename):
                return "Could not create URL for file: \(filename)"
            case .fileLoadError(let error):
                return "Failed to load file: \(error.localizedDescription)"
            case .videoProcessingError(let error):
                return "Failed to process video content: \(error.localizedDescription)"
            case .audioProcessingError(let error):
                return "Failed to process audio content: \(error.localizedDescription)"
            case .fileUploadError(let error):
                return "Failed to upload file: \(error.localizedDescription)"
            case .fileDeleteError(let error):
                return "Failed to delete file: \(error.localizedDescription)"
            case .fileRetrievalError(let error):
                return "Failed to retrieve file: \(error.localizedDescription)"
        }
    }
}
