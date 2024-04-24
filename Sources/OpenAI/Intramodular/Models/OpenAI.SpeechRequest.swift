//
//  File.swift
//  
//
//  Created by Natasha Murashev on 4/24/24.
//

import Foundation

public struct SpeechRequest {
    
    public init(input: StringOf4096CharOrLess,
                model: OpenAI.Model.Speech,
                voice: Voice,
                responseFormat: ResponseFormat? = nil,
                speed: ValidatedSpeed? = nil) {
        self.input = input
        self.model = model
        self.voice = voice
        self.responseFormat = responseFormat
        self.speed = speed
    }
    
    /// Encapsulates the voices available for audio generation.

    /// The text to generate audio for. The maximum length is 4096 characters.
    public let input: StringOf4096CharOrLess
    
    /// One of the available TTS models: tts-1 or tts-1-hd
    public let model: OpenAI.Model.Speech
    
    /// To get aquinted with each of the voices and listen to the samples visit:
    /// [OpenAI Text-to-Speech – Voice Options](https://platform.openai.com/docs/guides/text-to-speech/voice-options)
    public enum Voice: String, Codable, CaseIterable {
        case alloy
        case echo
        case fable
        case onyx
        case nova
        case shimmer
    }
    /// The voice to use when generating the audio. Supported voices are alloy, echo, fable, onyx, nova, and shimmer. Previews of the voices are available in the Text to speech guide.
    /// https://platform.openai.com/docs/guides/text-to-speech/voice-options
    public let voice: Voice
    

    /// The format to audio in. Supported formats are mp3, opus, aac, and flac.
    /// Defaults to mp3
    public enum ResponseFormat: String, Codable, CaseIterable {
        case mp3
        /// Opus: For internet streaming and communication, low latency.
        case opus
        /// AAC: For digital audio compression, preferred by YouTube, Android, iOS.
        case aac
        /// FLAC: For lossless audio compression, favored by audio enthusiasts for archiving.
        case flac
    }
    public let responseFormat: ResponseFormat?
    private var defaultResponseFormat: ResponseFormat {
        if let responseFormat = responseFormat {
            return responseFormat
        } else {
            return .mp3
        }
    }
    
    /// The speed of the generated audio. Select a value from **0.25** to **4.0**. **1.0** is the default.
    /// Defaults to 1
    public let speed: ValidatedSpeed?
    private var defaultSpeed: String {
        if let speed = speed {
            return "\(speed)"
        } else {
            return "\(ValidatedSpeed.Speed.normal.rawValue)"
        }
    }
    
    public func request(fromClient client: OpenAI.APIClient) async throws -> OpenAI.Speech? {
        
        let createSpeechRequest = OpenAI.APISpecification.RequestBodies.CreateSpeech(
            model: model,
            input: input.string,
            voice: voice.rawValue,
            responseFormat: defaultResponseFormat.rawValue,
            speed: defaultSpeed)
        
        do {
            let speech = try await client.createSpeech(requestBody: createSpeechRequest)
            return speech
        } catch {
            print(error)
            return nil
        }
    }
}

extension SpeechRequest {
    /// A struct to encapsulate a string that is validated to be 4096 characters or less.
    public struct StringOf4096CharOrLess {
        private var value: String

        /// The string value, guaranteed to be 4096 characters or less.
        public var string: String {
            return value
        }

        /// Initializes a ValidatedString with a given string.
        /// Throws an error if the string is more than 4096 characters.
        ///
        /// - Parameter string: The string to validate and store.
        /// - Throws: An error if the string exceeds 4096 characters.
        init(string: String) throws {
            guard string.count <= 4096 else {
                throw ValidationError.stringTooLong(string.count)
            }
            self.value = string
        }

        /// Error types for string validation failures.
        enum ValidationError: Error, CustomStringConvertible {
            case stringTooLong(Int)

            var description: String {
                switch self {
                case .stringTooLong(let count):
                    return "String is too long: \(count) characters (max 4096 allowed)."
                }
            }
        }
    }
}

extension SpeechRequest {
    public struct ValidatedSpeed {
        private var value: Double

        /// The speed value, guaranteed to be between 0.25 and 4.0.
        public var speed: Double {
            return value
        }

        enum Speed: Double {
            case normal = 1.0
            case max = 4.0
            case min = 0.25
        }
        
        public init(speed: Double) throws {
            guard speed >= Speed.min.rawValue && speed <= Speed.max.rawValue else {
                throw ValidationError.invalidSpeed(speed)
            }
            self.value = speed
        }

        /// Error types for speed validation failures.
        enum ValidationError: Error, CustomStringConvertible {
            case invalidSpeed(Double)

            var description: String {
                switch self {
                case .invalidSpeed(let speed):
                    return "Invalid speed: \(speed). Speed must be between 0.25 and 4.0."
                }
            }
        }
    }
}


