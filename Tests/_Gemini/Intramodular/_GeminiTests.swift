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
    @Test func testVideoContentGeneration() async throws {
        do {
            guard let url = URL(string: "https://file-examples.com/storage/fefaeec240676402c9bdb74/2017/04/file_example_MP4_640_3MG.mp4") else {
                throw GeminiTestError.invalidURL("https://file-examples.com/storage/fefaeec240676402c9bdb74/2017/04/file_example_MP4_640_3MG.mp4")
            }
            
            let messages = [_Gemini.Message(role: .user, content: "What is happening in this video?")]
            
            let content = try await client.generateContent(
                messages: messages,
                fileSource: .remoteURL(url),
                mimeType: .custom("video/mp4"),
                model: .gemini_1_5_flash
            )
            
            #expect(!content.text.isEmpty)
            
            print("Response text: \(content.text)")
            if let tokenUsage = content.tokenUsage {
                print("Token usage - Total: \(tokenUsage.total)")
            }
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(Bool(false), "Video content generation failed: \(error)")
        } catch {
            throw GeminiTestError.videoProcessingError(error)
        }
    }
    
    @Test func testAudioContentGeneration() async throws {
        do {
            guard let url = URL(string: "https://file-examples.com/storage/fefaeec240676402c9bdb74/2017/11/file_example_WAV_10MG.wav") else {
                throw GeminiTestError.invalidURL("https://file-examples.com/storage/fefaeec240676402c9bdb74/2017/11/file_example_WAV_10MG.wav")
            }
            
            let messages = [_Gemini.Message(role: .user, content: "What is being said in this audio?")]
            
            let content = try await client.generateContent(
                messages: messages,
                fileSource: .remoteURL(url),
                mimeType: .wav,
                model: .gemini_1_5_flash
            )
            
            print("Generated content: \(content)")
            
            #expect(!content.text.isEmpty)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(Bool(false), "Audio content generation failed: \(error)")
        } catch {
            throw GeminiTestError.audioProcessingError(error)
        }
    }
    
    @Test func testImageContentGeneration() async throws {
        do {
            guard let url = URL(string: "https://file-examples.com/storage/fefaeec240676402c9bdb74/2017/10/file_example_PNG_2100kB.png") else {
                throw GeminiTestError.invalidURL("https://file-examples.com/storage/fefaeec240676402c9bdb74/2017/10/file_example_PNG_2100kB.png")
            }
            
            let messages = [_Gemini.Message(role: .user, content: "What is in this image?")]
            
            let content = try await client.generateContent(
                messages: messages,
                fileSource: .remoteURL(url),
                mimeType: .custom("image/png"),
                model: .gemini_1_5_flash
            )
            
            print("Generated content: \(content)")
            
            #expect(!content.text.isEmpty)
        } catch let error as GeminiTestError {
            print("Detailed error: \(error.localizedDescription)")
            #expect(Bool(false), "Image content generation failed: \(error)")
        } catch {
            throw GeminiTestError.imageProcessingError(error)
        }
    }
}

// Error Handling
fileprivate enum GeminiTestError: LocalizedError {
    case invalidURL(String)
    case videoProcessingError(Error)
    case audioProcessingError(Error)
    case imageProcessingError(Error)
    
    var errorDescription: String? {
        switch self {
            case .invalidURL(let url):
                return "Invalid URL provided: \(url)"
            case .videoProcessingError(let error):
                return "Failed to process video content: \(error.localizedDescription)"
            case .audioProcessingError(let error):
                return "Failed to process audio content: \(error.localizedDescription)"
            case .imageProcessingError(let error):
                return "Failed to process image content: \(error.localizedDescription)"
        }
    }
}
