//
// Copyright (c) Vatsal Manot
//

import LargeLanguageModels
import Merge
import NetworkKit

extension Ollama {
    public struct APISpecification {
        public var host: URL
        
        public init(host: URL = URL(string: "http://localhost:11434")!) {
            self.host = host
        }
    }
}

extension Ollama.APISpecification {
    public enum RequestBodies {
        
    }
    
    public enum ResponseBodies {
        
    }
}

extension Ollama {
    enum _Endpoint {
        case root
        case models
        case modelInfo(data: Ollama.APISpecification.RequestBodies.GetModelInfo)
        case generate(data: Ollama.APISpecification.RequestBodies.GenerateCompletion)
        case chat(data: Ollama.APISpecification.RequestBodies.GenerateChatCompletion)
        case copyModel(data: Ollama.APISpecification.RequestBodies.CopyModel)
        case deleteModel(data: Ollama.APISpecification.RequestBodies.DeleteModel)
        
        fileprivate var path: String {
            switch self {
                case .root:
                    return "/"
                case .models:
                    return "/api/tags"
                case .modelInfo:
                    return "/api/show"
                case .generate:
                    return "/api/generate"
                case .chat:
                    return "/api/chat"
                case .copyModel:
                    return "/api/copy"
                case .deleteModel:
                    return "/api/delete"
            }
        }
        
        fileprivate var method: HTTPMethod {
            switch self {
                case .root:
                    return .head
                case .models:
                    return .get
                case .modelInfo:
                    return .post
                case .generate:
                    return .post
                case .chat:
                    return .post
                case .copyModel:
                    return .post
                case .deleteModel:
                    return .delete
            }
        }
        
        fileprivate var headers: [HTTPHeaderField] {
            [.contentType(.json)]
        }
        
        fileprivate var body: (any Encodable)? {
            switch self {
                case .modelInfo(let data):
                    return data
                case .generate(let data):
                    return data
                case .chat(let data):
                    return data
                case .copyModel(let data):
                    return data
                case .deleteModel(let data):
                    return data
                case .root:
                    return nil
                case .models:
                    return nil
            }
        }
        
        static var _apiSpecification = Ollama.APISpecification() // FIXME: !!!
        
        func asURLRequest() throws -> HTTPRequest {
            return try HTTPRequest(url: Self._apiSpecification.host.appendingPathComponent(path))
                .method(method)
                .header(headers)
                .jsonBody(body, keyEncodingStrategy: .convertToSnakeCase)
        }
    }
}
