//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Merge
import NetworkKit

extension Ollama.APISpecification.RequestBodies {
    public struct GetModelInfo: Encodable {
        public let name: Ollama.Model.ID
        
        public init(name: Ollama.Model.ID) {
            self.name = name
        }
    }

    public struct CopyModel: Encodable {
        public let source: String
        public let destination: String
        
        public init(source: String, destination: String) {
            self.source = source
            self.destination = destination
        }
    }
    
    public struct DeleteModel: Encodable {
        public let name: String
        
        public init(name: String) {
            self.name = name
        }
    }
    
    public struct GenerateCompletion: Codable, Hashable, Sendable {
        public enum Format: String, Codable, Hashable, Sendable {
            case json
        }

        private var stream: Bool
        
        public let model: Ollama.Model.ID
        public let prompt: String
        public var format: Format?
        public var system: String?
        public var template: String?
        public var options: Ollama.Modelfile.Options?
        public var context: [Int]?
        public var raw: Bool?
                        
        public init(
            stream: Bool,
            model: Ollama.Model.ID,
            prompt: String,
            format: Format? = nil,
            system: String? = nil,
            template: String? = nil,
            options: Ollama.Modelfile.Options? = nil,
            context: [Int]? = nil,
            raw: Bool? = nil
        ) {
            self.stream = stream
            self.model = model
            self.prompt = prompt
            self.format = format
            self.system = system
            self.template = template
            self.options = options
            self.context = context
            self.raw = raw
        }
    }
    
    public struct GenerateChatCompletion: Codable, Hashable, Sendable {
        public enum Format: String, Codable, Hashable, Sendable {
            case json
        }
        
        public let model: Ollama.Model.ID
        public let messages: [Ollama.ChatMessage]
        
        public var format: Format?
        public var options: Ollama.Modelfile.Options?
        public var template: String?
        public var stream: Bool
        
        public init(
            model: Ollama.Model.ID,
            messages: [Ollama.ChatMessage],
            format: Format? = nil,
            options: Ollama.Modelfile.Options? = nil,
            template: String? = nil,
            stream: Bool = false
        ) {
            self.model = model
            self.messages = messages
            self.format = format
            self.options = options
            self.template = template
            self.stream = stream
        }
    }
}

extension Ollama {
    public struct Modelfile {
        public struct Options: Codable, Hashable, Sendable {
            public var mirostat: Int?
            public var mirostatEta: Double?
            public var mirostatTau: Double?
            public var numCtx: Int?
            public var numGqa: Int?
            public var numGpu: Int?
            public var numThread: Int?
            public var repeatLastN: Int?
            public var repeatPenalty: Int?
            public var temperature: Double?
            public var seed: Int?
            public var stop: String?
            public var tfsZ: Double?
            public var numPredict: Int?
            public var topK: Int?
            public var topP: Double?
            
            public init(
                mirostat: Int? = nil,
                mirostatEta: Double? = nil,
                mirostatTau: Double? = nil,
                numCtx: Int? = nil,
                numGqa: Int? = nil,
                numGpu: Int? = nil,
                numThread: Int? = nil,
                repeatLastN: Int? = nil,
                repeatPenalty: Int? = nil,
                temperature: Double? = nil,
                seed: Int? = nil,
                stop: String? = nil,
                tfsZ: Double? = nil,
                numPredict: Int? = nil,
                topK: Int? = nil,
                topP: Double? = nil
            ) {
                self.mirostat = mirostat
                self.mirostatEta = mirostatEta
                self.mirostatTau = mirostatTau
                self.numCtx = numCtx
                self.numGqa = numGqa
                self.numGpu = numGpu
                self.numThread = numThread
                self.repeatLastN = repeatLastN
                self.repeatPenalty = repeatPenalty
                self.temperature = temperature
                self.seed = seed
                self.stop = stop
                self.tfsZ = tfsZ
                self.numPredict = numPredict
                self.topK = topK
                self.topP = topP
            }
        }
    }
}
