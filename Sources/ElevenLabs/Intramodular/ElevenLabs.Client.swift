//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import Foundation
import NetworkKit

public struct ElevenLabsAPI: RESTAPISpecification {
    public var apiKey: String
    public var host = URL(string: "https://api.elevenlabs.io")!
    
    public init(apiKey: String) {
        self.apiKey = apiKey
    }
    
    public var baseURL: URL {
        host.appendingPathComponent("/v1")
    }
    
    public var id: some Hashable {
        apiKey
    }
    
    // List Voices endpoint
    @Path("voices")
    @GET
    var listVoices = Endpoint<Void, ResponseBodies.Voices, Void>()
    
    // Text to Speech endpoint
    @Path("text-to-speech/{voiceId}")
    @POST
    @Body({ context in
        RequestBodies.SpeechRequest(
            text: context.input.text,
            voiceSettings: context.input.voiceSettings,
            model: context.input.model
        )
    })
    var textToSpeech = Endpoint<RequestBodies.TextToSpeechInput, Data, Void>()
    
    // Speech to Speech endpoint
    @Path("speech-to-speech/{voiceId}/stream")
    @POST
    var speechToSpeech = MultipartEndpoint<RequestBodies.SpeechToSpeechInput, Data, Void>()
    
    // Add Voice endpoint
    @Path("voices/add")
    @POST
    var addVoice = MultipartEndpoint<RequestBodies.AddVoiceInput, ResponseBodies.VoiceID, Void>()
    
    // Edit Voice endpoint
    @Path("voices/{voiceId}/edit")
    @POST
    var editVoice = MultipartEndpoint<RequestBodies.EditVoiceInput, Bool, Void>()
    
    // Delete Voice endpoint
    @Path("voices/{voiceId}")
    @DELETE
    var deleteVoice = Endpoint<String, Void, Void>()
}

extension ElevenLabsAPI {
    public final class Endpoint<Input, Output, Options>: BaseHTTPEndpoint<ElevenLabsAPI, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            let request = try super.buildRequestBase(from: input, context: context)
                .header("xi-api-key", context.root.apiKey)
                .header(.contentType(.json))
            
            return request
        }
        
        override public func decodeOutputBase(
            from response: Request.Response,
            context: DecodeOutputContext
        ) throws -> Output {
            try response.validate()
            
            if Output.self == Data.self {
                return response.data as! Output
            }
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
    
    public final class MultipartEndpoint<Input, Output, Options>: BaseHTTPEndpoint<ElevenLabsAPI, Input, Output, Options> {
        override public func buildRequestBase(
            from input: Input,
            context: BuildRequestContext
        ) throws -> Request {
            let boundary = UUID().uuidString
            var request = try super.buildRequestBase(from: input, context: context)
                .header("xi-api-key", context.root.apiKey)
                .header(.contentType(.multipartFormData(boundary: boundary)))
            
            var data = Data()
            
            switch input {
            case let input as RequestBodies.SpeechToSpeechInput:
                data.append(input.createMultipartFormData(boundary: boundary))
            case let input as RequestBodies.AddVoiceInput:
                data.append(input.createMultipartFormData(boundary: boundary))
            case let input as RequestBodies.EditVoiceInput:
                data.append(input.createMultipartFormData(boundary: boundary))
            default:
                throw Never.Reason.unexpected
            }
            
            request.httpBody = data
            
            return request
        }
        
        override public func decodeOutputBase(
            from response: Request.Response,
            context: DecodeOutputContext
        ) throws -> Output {
            try response.validate()
            
            if Output.self == Data.self {
                return response.data as! Output
            }
            
            return try response.decode(
                Output.self,
                keyDecodingStrategy: .convertFromSnakeCase
            )
        }
    }
}

// Request and Response Bodies
extension ElevenLabsAPI {
    public enum RequestBodies {
        public struct SpeechRequest: Codable {
            let text: String
            let voiceSettings: ElevenLabs.VoiceSettings
            let model: ElevenLabs.Model
        }
        
        public struct TextToSpeechInput {
            let voiceId: String
            let text: String
            let voiceSettings: ElevenLabs.VoiceSettings
            let model: ElevenLabs.Model
        }
        
        public struct SpeechToSpeechInput {
            let voiceId: String
            let audioURL: URL
            let voiceSettings: ElevenLabs.VoiceSettings
            let model: ElevenLabs.Model
            
            func createMultipartFormData(boundary: String) -> Data {
                var data = Data()
                
                // Add model_id
                data.append("--\(boundary)\r\n".data(using: .utf8)!)
                data.append("Content-Disposition: form-data; name=\"model_id\"\r\n\r\n".data(using: .utf8)!)
                data.append("\(model.rawValue)\r\n".data(using: .utf8)!)
                
                // Add voice settings
                let encoder = JSONEncoder()
                encoder.keyEncodingStrategy = .convertToSnakeCase
                if let voiceSettingsData = try? encoder.encode(voiceSettings),
                   let voiceSettingsString = String(data: voiceSettingsData, encoding: .utf8) {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"voice_settings\"\r\n\r\n".data(using: .utf8)!)
                    data.append("\(voiceSettingsString)\r\n".data(using: .utf8)!)
                }
                
                // Add audio file
                if let fileData = try? Data(contentsOf: audioURL) {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"audio\"; filename=\"\(audioURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: audio/mpeg\r\n\r\n".data(using: .utf8)!)
                    data.append(fileData)
                    data.append("\r\n".data(using: .utf8)!)
                }
                
                data.append("--\(boundary)--\r\n".data(using: .utf8)!)
                return data
            }
        }
        
        public struct AddVoiceInput {
            let name: String
            let description: String
            let fileURL: URL
            
            func createMultipartFormData(boundary: String) -> Data {
                var data = Data()
                
                // Add name and description
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
                
                // Add audio file
                if let fileData = try? Data(contentsOf: fileURL) {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: audio/x-wav\r\n\r\n".data(using: .utf8)!)
                    data.append(fileData)
                    data.append("\r\n".data(using: .utf8)!)
                }
                
                data.append("--\(boundary)--\r\n".data(using: .utf8)!)
                return data
            }
        }
        
        public struct EditVoiceInput {
            let voiceId: String
            let name: String
            let description: String
            let fileURL: URL
            
            func createMultipartFormData(boundary: String) -> Data {
                var data = Data()
                
                // Add name and description
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
                
                // Add audio file
                if let fileData = try? Data(contentsOf: fileURL) {
                    data.append("--\(boundary)\r\n".data(using: .utf8)!)
                    data.append("Content-Disposition: form-data; name=\"files\"; filename=\"\(fileURL.lastPathComponent)\"\r\n".data(using: .utf8)!)
                    data.append("Content-Type: audio/x-wav\r\n\r\n".data(using: .utf8)!)
                    data.append(fileData)
                    data.append("\r\n".data(using: .utf8)!)
                }
                
                data.append("--\(boundary)--\r\n".data(using: .utf8)!)
                return data
            }
        }
    }
    
    public enum ResponseBodies {
        public struct Voices: Codable {
            public let voices: [ElevenLabs.Voice]
        }
        
        public struct VoiceID: Codable {
            public let voiceId: String
        }
    }
}
