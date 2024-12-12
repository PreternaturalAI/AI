//
//  Untitled.swift
//  AI
//
//  Created by Jared Davidson on 12/11/24.
//

import Testing
import SwiftUIX
import Foundation
import _Gemini

@Suite struct GeminiTests {
    func loadTestFileURL(named filename: String, fileExtension: String) throws -> URL {
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
        
        return resourcePath
    }
    
    func loadTestFile(named filename: String, fileExtension: String) throws -> Data {
        let url = try loadTestFileURL(named: filename, fileExtension: fileExtension)
        do {
            return try Data(contentsOf: url)
        } catch {
            throw GeminiTestError.fileLoadError(error)
        }
    }
    
    @Test func testVideoContentGeneration() async throws {
        do {
            let file = try await createFile(type: .video)
            
            let content = try await client.generateContent(
                file: file,
                prompt: "What is happening in this video?",
                model: .gemini_1_5_flash
            )
            
            #expect(!content.text.isEmpty)
            #expect(content.finishReason != nil)
            #expect(!content.safetyRatings.isEmpty)
            
            print("Response text: \(content.text)")
            if let tokenUsage = content.tokenUsage {
                print("Token usage - Total: \(tokenUsage.total)")
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
            let file = try await createFile(type: .audio)
            
            let content = try await client.generateContent(
                file: file,
                prompt: "What is being said in this audio?",
                model: .gemini_1_5_flash
            )
            
            print("Generated content: \(content)")
            
            #expect(!content.text.isEmpty)
            #expect(content.finishReason != nil)
            #expect(!content.safetyRatings.isEmpty)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "Audio content generation failed: \(error)")
        } catch {
            throw GeminiTestError.audioProcessingError(error)
        }
    }
    
    @Test func testImageContentGeneration() async throws {
        do {
            let file = try await createFile(type: .image)
            
            let content = try await client.generateContent(
                file: file,
                prompt: "What is this the shape of this image?",
                model: .gemini_1_5_flash
            )
            
            print("Generated content: \(content)")
            
            #expect(!content.text.isEmpty)
            #expect(content.finishReason != nil)
            #expect(!content.safetyRatings.isEmpty)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "Image content generation failed: \(error)")
        } catch {
            throw GeminiTestError.imageProcessingError(error)
        }
    }
    
    @Test func testImageContentGenerationWithURL() async throws {
        do {
            let url = try loadTestFileURL(named: "LintMySwift2", fileExtension: "m4a")
            let content = try await client.generateContent(
                url: url,
                type: .custom("audio/x-m4a"),
                prompt: "What does this audio say?",
                model: .gemini_1_5_flash
            )
            
            print("Generated content: \(content)")
            
            #expect(!content.text.isEmpty)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "URL content generation failed: \(error)")
        } catch {
            throw GeminiTestError.audioProcessingError(error)
        }
    }
    
    @Test func testFileUpload() async throws {
        do {
            let file = try await createFile(type: .audio)
            #expect(file.name != nil)
            #expect(file.mimeType != nil)
            #expect(file.state == .active || file.state == .processing)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "File upload failed: \(error)")
        } catch {
            throw GeminiTestError.fileUploadError(error)
        }
    }
    
    @Test func testGetFile() async throws {
        do {
            let file = try await createFile(type: .audio)
            let retrievedFile = try await client.getFile(name: file.name ?? "")
            #expect(retrievedFile.name == file.name)
            #expect(retrievedFile.mimeType == file.mimeType)
            #expect(retrievedFile.uri == file.uri)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "File retrieval failed: \(error)")
        } catch {
            throw GeminiTestError.fileRetrievalError(error)
        }
    }
    
    @Test func testFileDelete() async throws {
        do {
            let file = try await createFile(type: .audio)
            try await client.deleteFile(fileURL: file.uri)
            #expect(true)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(false, "File deletion failed: \(error)")
        } catch {
            throw GeminiTestError.fileDeleteError(error)
        }
    }
    
    func createFile(type: TestFileType) async throws -> _Gemini.File {
        do {
            switch type {
                case .audio:
                    let audioData = try loadTestFile(named: "LintMySwift2", fileExtension: "m4a")
                    
                    return try await client.uploadFile(
                        fileData: audioData,
                        mimeType: .custom("audio/x-m4a"),
                        displayName: "Test"
                    )
                case .video:
                    let videoData = try loadTestFile(named: "LintMySwiftSmall", fileExtension: "mov")
                    
                    return try await client.uploadFile(
                        fileData: videoData,
                        mimeType: .custom("video/quicktime"),
                        displayName: "Test"
                    )
                case .image:
                    let image = AppKitOrUIKitImage(_SwiftUIX_systemName: "arrow.up", withConfiguration: .init(pointSize: 50))
                    guard let imageData = image?.data(using: .png) else { throw GeminiTestError.fileNotFound("System Symbol")}
                    
                    return try await client.uploadFile(
                        fileData: imageData,
                        mimeType: .custom("image/png"),
                        displayName: "Test"
                    )
            }
        } catch let error as GeminiTestError {
            throw error
        } catch {
            throw GeminiTestError.fileUploadError(error)
        }
    }
    
    enum TestFileType {
        case audio
        case video
        case image
    }
}

// Error Handling
fileprivate enum GeminiTestError: LocalizedError {
    case fileNotFound(String)
    case invalidFileURL(String)
    case fileLoadError(Error)
    case videoProcessingError(Error)
    case audioProcessingError(Error)
    case imageProcessingError(Error)
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
            case .imageProcessingError(let error):
                return "Failed to process image content: \(error.localizedDescription)"
            case .fileUploadError(let error):
                return "Failed to upload file: \(error.localizedDescription)"
            case .fileDeleteError(let error):
                return "Failed to delete file: \(error.localizedDescription)"
            case .fileRetrievalError(let error):
                return "Failed to retrieve file: \(error.localizedDescription)"
        }
    }
}
