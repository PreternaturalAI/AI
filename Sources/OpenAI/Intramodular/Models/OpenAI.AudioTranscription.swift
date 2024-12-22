//
// Copyright (c) Vatsal Manot
//

import FoundationX

extension OpenAI {
    public final class AudioTranscription: OpenAI.Object {
        fileprivate enum CodingKeys: CodingKey {
            case language
            case duration
            case text
            case words
            case segments
        }

        public private(set) var language: String?
        public private(set) var duration: Double?
        public private(set) var text: String
        public private(set) var words: [Word]?
        public private(set) var segments: [TranscriptionSegment]?

        public init(
            language: String?,
            duration: Double?,
            text: String,
            words: [Word]?,
            segments: [TranscriptionSegment]?
        ) {
            self.language = language
            self.duration = duration
            self.text = text
            self.words = words
            self.segments = segments
            
            super.init(type: .transcription)
        }
                
        public required init(from decoder: Decoder) throws {
            do {
                let container = try decoder.container(keyedBy: CodingKeys.self)
                
                self.language = try container.decodeIfPresent(forKey: .language)
                self.duration = try container.decodeIfPresent(forKey: .duration)
                self.text = try container.decode(forKey: .text)
                self.words = try container.decodeIfPresent(forKey: .words)
                self.segments = try container.decodeIfPresent(forKey: .segments)
                
                super.init(type: .transcription)
            } catch {
                do {
                    let string = try String(from: decoder)
                    
                    self.language = nil
                    self.duration = nil
                    self.text = string
                    self.words = nil
                    self.segments = nil
                    
                    super.init(type: .transcription)
                } catch(_) {
                    throw error
                }
            }
        }
        
        override public func encode(to encoder: any Encoder) throws {
            try super.encode(to: encoder)
            
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(language, forKey: .text)
            try container.encode(duration, forKey: .text)
            try container.encode(text, forKey: .text)
            try container.encode(words, forKey: .text)
            try container.encode(segments, forKey: .text)
        }
    }
}

extension OpenAI.AudioTranscription {
    public enum ResponseFormat: String, Codable, CaseIterable {
        case json
        case text
        case srt
        case verboseJSON = "verbose_json"
        case vtt
    }
}

extension OpenAI.AudioTranscription {
    /// The timestamp granularities to populate for this transcription. response_format must be set verbose_json to use timestamp granularities. Either or both of these options are supported: word, or segment. Note: There is no additional latency for segment timestamps, but generating word timestamps incurs additional latency.
    public enum TimestampGranularity: String, Codable, CaseIterable {
        case word
        case segment
    }

    public struct TranscriptionSegment: Codable, Hashable, Sendable {
        enum CodingKeys: String, CodingKey {
            case id
            case seek
            case start
            case end
            case text
            case tokens
            case temperature
            case averageLogprob = "avg_logprob"
            case compressionRatio = "compression_ratio"
            case noSpeechProb = "no_speech_prob"
        }
        
        public let id: Int
        public let seek: Int
        public let start: Double
        public let end: Double
        public let text: String
        public let tokens: [Int]?
        public let temperature: Double?
        public let averageLogprob: Double?
        public let compressionRatio: Double?
        public let noSpeechProb: Double?
    }
    
    public struct Word: Codable, Hashable, Sendable {
        /// The text content of the word.
        public let word: String
        /// Start time of the word in seconds.
        public let start: Double
        /// End time of the word in seconds.
        public let end: Double
    }
}

// MARK: - Conformances

extension OpenAI.AudioTranscription: CustomStringConvertible {
    public var description: String {
        text
    }
}
