//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import Foundation
import Merge
import NetworkKit
import Swallow

extension OpenAI {
    public final class ChatCompletionSession: Logging {
        private let queue = DispatchQueue()
        private let client: OpenAI.Client
        private let session: URLSession
        private let sessionDelegate = _URLSessionDataDelegate()

        private var eventSource: SSE.EventSource?
        
        public init(
            client: OpenAI.Client
        ) {
            self.client = client
            
            session = URLSession(
                configuration: URLSessionConfiguration.default,
                delegate: sessionDelegate,
                delegateQueue: nil
            )
        }
    }
}

extension OpenAI.ChatCompletionSession {
    private static let encoder = JSONEncoder(keyEncodingStrategy: .convertToSnakeCase)
    private static let decoder = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase)._polymorphic()
    
    private var key: String {
        get throws {
            try client.interface.configuration.apiKey.unwrap()
        }
    }
    
    private func makeURLRequest(
        data: Data
    ) throws -> URLRequest {
        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        
        request.httpMethod = "POST"
        
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        try request.setValue("Bearer \(key)", forHTTPHeaderField: "Authorization")
        
        request.httpBody = data
        
        return request
    }
    
    public func _WIP_complete(
        messages: [OpenAI.ChatMessage],
        model: OpenAI.Model,
        parameters: OpenAI.Client.ChatCompletionParameters
    ) async throws -> AnyPublisher<OpenAI.ChatMessage, Error> {
        var _self: OpenAI.ChatCompletionSession! = self
        
        let chatRequest = OpenAI.APISpecification.RequestBodies.CreateChatCompletion(
            messages: messages,
            model: model,
            parameters: parameters,
            stream: true
        )
        
        let data: Data = try Self.encoder.encode(chatRequest)
        let request: URLRequest = try makeURLRequest(data: data)
        
        let responseMessage = _LockedState(
            initialState: OpenAI.ChatMessage(
                role: .assistant,
                content: ""
            )
        )
        
        let eventSource = SSE.EventSource(request: request)
          
        self.eventSource = eventSource
                
        return eventSource
            .receive(on: queue)
            .tryMap({ event -> ChatCompletionEvent? in
                switch event {
                    case .open:
                        return nil
                    case .message(let message):
                        if let data: Data = message.data?.data(using: .utf8) {
                            guard message.data != "[DONE]" else {
                                _self.eventSource?.shutdown()
                                
                                return .stop
                            }
                            
                            let completion = try Self.decoder.decode(OpenAI.ChatCompletionChunk.self, from: data)
                            let choice: OpenAI.ChatCompletionChunk.Choice = try completion.choices.toCollectionOfOne().first
                            let delta = choice.delta
                            
                            if let deltaContent = delta.content {
                                try responseMessage.withLock {
                                    try $0.body += deltaContent
                                }
                            }
                            
                            return ChatCompletionEvent.message(responseMessage.withLock({ $0 }))
                        } else {
                            assertionFailure()
                            
                            return nil
                        }
                    case .error(let error):
                        runtimeIssue(error)
                        
                        _self.eventSource = nil
                        
                        return nil
                    case .closed:
                        _self.eventSource = nil
                        _self = nil
                        
                        return nil
                }
            })
            .compactMap({ (value: ChatCompletionEvent?) -> ChatCompletionEvent? in
                value
            })
            .tryMap({ try $0.message.unwrap() })
            .onSubscribe(perform: eventSource.connect)
            .eraseToAnyPublisher()
    }
    
    enum ChatCompletionEvent: Hashable {
        case message(OpenAI.ChatMessage)
        case stop
        
        var message: OpenAI.ChatMessage? {
            guard case .message(let message) = self else {
                return nil
            }
            
            return message
        }
    }
}
extension OpenAI.ChatCompletionSession {
    public func complete(
        messages: [OpenAI.ChatMessage],
        model: OpenAI.Model,
        parameters: OpenAI.Client.ChatCompletionParameters
    ) async throws -> AnyPublisher<OpenAI.ChatMessage, Error> {
        let bytes = try await _complete(
            messages: messages,
            model: model,
            parameters: parameters
        )
        
        var responseMessage = OpenAI.ChatMessage(
            id: UUID().uuidString,
            role: .assistant,
            body: ""
        )
        
        return _stream(bytes: bytes) { response in
            let delta = try response.choices.first.unwrap().delta
            
            if let deltaContent = delta.content {
                try responseMessage.body += deltaContent
            }
            
            return responseMessage
        }
        .eraseToAnyAsyncSequence()
        .publisher()
        .eraseToAnyPublisher()
    }

    private func _complete(
        messages: [OpenAI.ChatMessage],
        model: OpenAI.Model,
        parameters: OpenAI.Client.ChatCompletionParameters
    ) async throws -> URLSession.AsyncBytes {
        let chatRequest = OpenAI.APISpecification.RequestBodies.CreateChatCompletion(
            messages: messages,
            model: model,
            parameters: parameters,
            stream: true
        )
        
        let data = try Self.encoder.encode(chatRequest)
        let request = try makeURLRequest(data: data)
        
        let (bytes, response) = try await Task.retrying(maxRetryCount: 1) {
            try await Task(timeout: .seconds(3)) {
                try await self.session.bytes(for: request, delegate: self.sessionDelegate)
            }
            .value
        }
        .value
        
        guard
            let httpResponse = response as? HTTPURLResponse,
            httpResponse.statusCode == 200
        else {
            do {
                var iterator = bytes.lines.makeAsyncIterator()
                let lines = try await iterator.exhaust()
                let json = try JSON(jsonString: lines.joined(separator: ""))
                
                throw _Error.responseError(json)
            } catch {
                if error is _Error {
                    throw error
                } else {
                    throw _Error.responseError(nil)
                }
            }
        }
        
        return bytes
    }
    
    private func _stream<T>(
        bytes: URLSession.AsyncBytes,
        onEvent: @escaping (OpenAI.ChatCompletionChunk) throws -> T
    ) -> AsyncThrowingStream<T, Error> {
        return AsyncThrowingStream(bufferingPolicy: .unbounded) { continuation in
            Task(priority: .userInitiated) {
                do {
                    for try await line in bytes.lines {
                        if line.starts(with: "data: [DONE]") {
                            continuation.finish()
                            
                            return
                        } else if line.starts(with: "data: ") {
                            let rest = line.index(line.startIndex, offsetBy: 6)
                            let data: Data = line[rest...].data(using: .utf8)!
                            
                            do {
                                let response = try Self.decoder.decode(OpenAI.ChatCompletionChunk.self, from: data)
                                
                                continuation.yield(try onEvent(response))
                            } catch {
                                continuation.finish(throwing: error)
                            }
                        } else {
                            continuation.finish(throwing: _Error.streamIsInvalid)
                        }
                    }
                } catch {
                    continuation.finish(throwing: error)
                }
                
                throw _Error.streamIsInvalid
            }
        }
    }
}

extension OpenAI.ChatCompletionSession {
    fileprivate class _URLSessionDataDelegate: NSObject, Foundation.URLSessionDataDelegate {
        public func urlSession(
            _ session: URLSession,
            dataTask: URLSessionDataTask,
            didReceive data: Data
        ) {
            
        }
        
        public func urlSession(
            _ session: URLSession,
            dataTask: URLSessionDataTask,
            didReceive response: URLResponse
        ) async -> URLSession.ResponseDisposition {
            .allow
        }
    }
}

extension OpenAI.ChatCompletionSession {
    public enum _Error: Error {
        case responseError(JSON?)
        case streamIsInvalid
    }
}
