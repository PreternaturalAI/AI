//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import Swift

extension OpenAI {
    public enum ChatMessageBody: Hashable, Sendable {
        public struct FunctionCall: Codable, Hashable, Sendable {
            public let name: String
            public let arguments: String
            
            public init(name: String, arguments: String) {
                self.name = name
                self.arguments = arguments
            }
        }

        public struct FunctionInvocation: Codable, Hashable, Sendable {
            public let name: String
            public let response: String
            
            public init(name: String, response: String) {
                self.name = name
                self.response = response
            }
        }
        
        case text(String)
        case content([_Content])
        /// The call made to a function provided to the LLM.
        case functionCall(FunctionCall)
        /// The result of a function call of a function that was provided to the LLM.
        case functionInvocation(FunctionInvocation)
        
        func _coerceToContentArray() throws -> [_Content] {
            switch self {
                case .text(let text):
                    return [.text(text)]
                case .content(let content):
                    return content
                case .functionCall, .functionInvocation:
                    throw Never.Reason.unsupported
            }
        }
    }
}

// MARK: - Initializers

extension OpenAI.ChatMessageBody {
    public static func content(_ text: String) -> Self {
        .text(text)
    }
}

// MARK: - Extensions

extension OpenAI.ChatMessageBody {
    public var isEmpty: Bool {
        switch self {
            case .text(let text):
                return text.isEmpty
            case .content(let content):
                return content.isEmpty
            case .functionCall:
                return false
            case .functionInvocation:
                return false
        }
    }
    
    var _textValue: String? {
        guard case .text(let string) = self else {
            return nil
        }
        
        return string
    }

    public mutating func append(_ newText: String) throws {
        switch self {
            case .text(let text):
                self = .text(text.appending(contentsOf: newText))
            case .content(let content):
                self = .content(content.appending(.text(newText)))
            case .functionCall:
                throw Never.Reason.illegal
            case .functionInvocation:
                throw Never.Reason.illegal
        }
    }
    
    public static func += (lhs: inout Self, rhs: String) throws {
        try lhs.append(rhs)
    }
}

// MARK: - Auxiliary

extension OpenAI.ChatMessageBody {
    enum _ContentType: String, Codable, Hashable, Sendable {
        case text = "text"
        case imageURL = "image_url"
    }

    public enum _Content: Sendable {
        public struct ImageURL: Codable, Hashable, Sendable {
            /// https://platform.openai.com/docs/guides/vision/low-or-high-fidelity-image-understanding
            public enum ImageDetail: String, Codable, Hashable, Sendable {
                case low
                case high
                case auto
            }
            
            public let url: URL
            public let detail: ImageDetail
            
            public init(url: URL, detail: ImageDetail = .auto) {
                self.url = url
                self.detail = detail
            }
        }
        
        case text(String)
        case imageURL(ImageURL)
        
        public static func imageURL(_ url: URL) -> Self {
            Self.imageURL(ImageURL(url: url, detail: .auto))
        }
    }
}

// MARK: - Conformances

extension OpenAI.ChatMessageBody._Content: Codable {
    fileprivate enum CodingKeys: String, CodingKey {
        case type
        case text
        case imageURL = "image_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let contentType = try container.decode(OpenAI.ChatMessageBody._ContentType.self, forKey: .type)
        
        switch contentType {
            case .text:
                self = .text(try container.decode(String.self, forKey: .text))
            case .imageURL:
                self = .imageURL(try container.decode(ImageURL.self, forKey: .imageURL))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
            case .text(let text):
                try container.encode("text", forKey: .type)
                try container.encode(text, forKey: .text)
            case .imageURL(let imageURL):
                try container.encode("image_url", forKey: .type)
                try container.encode(imageURL, forKey: .imageURL)
        }
    }
}

extension OpenAI.ChatMessageBody: CustomStringConvertible {
    public var description: String {
        switch self {
            case .text(let text):
                return text.description
            case .content(let content):
                return content.description
            case .functionCall(let call):
                return "\(call.name)(\(call.arguments))"
            case .functionInvocation(let invocation):
                return "\(invocation.name)(...) = \(invocation.response)"
        }
    }
}

extension OpenAI.ChatMessageBody._Content: CustomStringConvertible {
    public var description: String {
        switch self {
            case .text(let text):
                return text.description
            case .imageURL(let imageURL):
                return imageURL.url.description
        }
    }
}

extension OpenAI.ChatMessageBody._Content: Hashable {
    public func hash(into hasher: inout Hasher) {
        switch self {
            case .text(let string):
                hasher.combine(string)
            case .imageURL(let url):
                hasher.combine(url)
        }
    }
    
    public static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
            case let (.text(a), .text(b)):
                return a == b
            case let (.imageURL(a), .imageURL(b)):
                return a == b
            default:
                return false
        }
    }
}
