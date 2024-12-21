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
            guard let url = URL(string: "https://devstreaming-cdn.apple.com/videos/wwdc/2024/10087/4/1BAC307D-DA03-4FDC-AB9B-F3B4494DE81E/downloads/wwdc2024-10087_sd.mp4") else {
                throw GeminiTestError.invalidURL("https://devstreaming-cdn.apple.com/videos/wwdc/2024/10087/4/1BAC307D-DA03-4FDC-AB9B-F3B4494DE81E/downloads/wwdc2024-10087_sd.mp4")
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
            guard let url = URL(string: "https://replicate.delivery/mgxm/e5159b1b-508a-4be4-b892-e1eb47850bdc/OSR_uk_000_0050_8k.wav") else {
                throw GeminiTestError.invalidURL("https://replicate.delivery/mgxm/e5159b1b-508a-4be4-b892-e1eb47850bdc/OSR_uk_000_0050_8k.wav")
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
            guard let url = URL(string: "https://upload.wikimedia.org/wikipedia/en/7/77/EricCartman.png") else {
                throw GeminiTestError.invalidURL("https://upload.wikimedia.org/wikipedia/en/7/77/EricCartman.png")
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
