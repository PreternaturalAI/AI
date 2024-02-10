//
// Copyright (c) Vatsal Manot
//

import CoreGML
import CorePersistence
import Foundation
import NetworkKit

public final class ElevenLabs: ObservableObject {
    public struct Configuration {
        public var apiKey: String?
    }
    
    public let configuration: Configuration
    public let apiSpecification = APISpecification()
    
    public required init(
        configuration: Configuration
    ) {
        self.configuration = configuration
    }
    
    public convenience init(
        apiKey: String?
    ) {
        self.init(configuration: .init(apiKey: apiKey))
    }
}

extension ElevenLabs {
    public func availableVoices() async throws -> [Voice] {
        let request = HTTPRequest(url: URL(string: "\(apiSpecification)/v1/voices")!)
            .method(.get)
            .header("xi-api-key", configuration.apiKey)
            .header(.contentType(.json))
        
        let response = try await HTTPSession.shared.data(for: request)
        
        try response.validate()
        
        return try response.decode(
            APISpecification.ResponseBodies.Voices.self,
            keyDecodingStrategy: .convertFromSnakeCase
        )
        .voices
    }
    
    @discardableResult
    public func speech(
        for text: String,
        voiceID: String,
        voiceSettings: [String: JSON]? = nil,
        model: String? = nil
    ) async throws -> Data {
        let request = try HTTPRequest(url: URL(string: "\(apiSpecification.host)/v1/text-to-speech/\(voiceID)")!)
            .method(.post)
            .header("xi-api-key", configuration.apiKey)
            .header(.contentType(.json))
            .header(.accept(.mpeg))
            .jsonBody(
                APISpecification.RequestBodies.SpeechRequest(
                    text: text,
                    voiceSettings: voiceSettings ?? [
                        "stability" : 0,
                        "similarity_boost": 0
                    ],
                    model: model
                ),
                keyEncodingStrategy: .convertToSnakeCase
            )
        
        let response = try await HTTPSession.shared.data(for: request)
        
        try response.validate()
        
        return response.data
    }
        
    public func upload(
        voiceWithName name: String,
        description: String,
        fileURL: URL
    ) async throws -> Voice.ID {
        let boundary = UUID().uuidString
        
        var request = try URLRequest(url: URL(string: "\(apiSpecification.host)/v1/voices/add").unwrap())
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        let parameters = [
            ("name", name),
            ("description", description),
            ("labels", "")
        ]
        
        for (key, value) in parameters {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        if let fileData = createMultipartData(boundary: boundary, name: "files", fileURL: fileURL, fileType: "audio/x-wav") {
            data.append(fileData)
        }
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        let voiceID: String? = try await withUnsafeThrowingContinuation { (continuation: UnsafeContinuation<String?, Error>) in
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let data = data {
                    if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                                continuation.resume(returning: json["voice_id"])
                            } else {
                                continuation.resume(returning: nil)
                            }
                            
                        } catch {
                            continuation.resume(throwing: _PlaceholderError())
                        }
                    } else {
                        continuation.resume(throwing: _PlaceholderError())
                    }
                }
            }
            
            task.resume()
        }
        
        return try .init(rawValue: voiceID.unwrap())
    }
    
    public func edit(
        voice: Voice.ID,
        name: String,
        description: String,
        fileURL: URL
    ) async throws -> Bool {
        let url = URL(string: "\(apiSpecification.host)/v1/voices/\(voice.rawValue)/edit")!
        
        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "xi-api-key")
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        let parameters = [
            ("name", name),
            ("description", description),
            ("labels", "")
        ]
        
        for (key, value) in parameters {
            data.append("--\(boundary)\r\n".data(using: .utf8)!)
            data.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            data.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        if let fileData = createMultipartData(boundary: boundary, name: "files", fileURL: fileURL, fileType: "audio/x-wav") {
            data.append(fileData)
        }
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = data
        
        let response = try await HTTPSession.shared.data(for: request)
        
        try response.validate()
        
        return true
    }
    
    public func delete(
        voice: Voice.ID
    ) async throws {
        let url = try URL(string: "\(apiSpecification.host)/v1/voices/\(voice.rawValue)").unwrap()
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "accept")
        request.setValue(configuration.apiKey, forHTTPHeaderField: "xi-api-key")
        
        let response = try await HTTPSession.shared.data(for: request)
        
        try response.validate()
    }
    
    private func createMultipartData(
        boundary: String,
        name: String,
        fileURL: URL,
        fileType: String
    ) -> Data? {
        var result = Data()
        let fileName = fileURL.lastPathComponent
        
        result.append("--\(boundary)\r\n".data(using: .utf8)!)
        result.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        result.append("Content-Type: \(fileType)\r\n\r\n".data(using: .utf8)!)
        
        guard let fileData = try? Data(contentsOf: fileURL) else {
            return nil
        }
        
        result.append(fileData)
        result.append("\r\n".data(using: .utf8)!)
        
        return result
    }
}
