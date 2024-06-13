//
// Copyright (c) Vatsal Manot
//

import CoreMI
import Diagnostics
import LargeLanguageModels
import NetworkKit
import Swallow

extension Ollama: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: Dependencies {
        var result = Dependencies()
        
        result[\.llm] = self
        
        return result
    }
}

extension Ollama: LLMRequestHandling {
    public var _availableModels: [ModelIdentifier]? {
        self._allKnownModels?.compactMap({ try? $0.__conversion() })
    }

    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion {
        if let prompt = prompt as? AbstractLLM.TextPrompt {
            let completion = try await _complete(
                prompt: prompt,
                parameters: try cast(parameters)
            )
            
            return completion as! Prompt.Completion
        }

        throw Never.Reason.unimplemented
    }
    
    private func _complete(
        prompt: AbstractLLM.TextPrompt,
        parameters: AbstractLLM.TextCompletionParameters
    ) async throws -> AbstractLLM.TextCompletion {
        var maxTokens: Int?
        
        switch parameters.tokenLimit {
            case .max:
                maxTokens = nil
            case .fixed(let count):
                maxTokens = count
        }
        
        let model = try await _model(for: prompt)
        let requestBody = Ollama.APISpecification.RequestBodies.GenerateCompletion(
            stream: false,
            model: model.id,
            prompt: try prompt.prefix._toPromptLiteral()._stripToText(),
            options: .init(numPredict: maxTokens)
        )
        
        let request: HTTPRequest = try Ollama._Endpoint
            .generate(data: requestBody)
            .asURLRequest()
        
        let response = try await HTTPSession.shared.task(with: request).value
                
        let responseBody = try response.decode(Ollama.APISpecification.ResponseBodies.GenerateCompletion.self, using: decoder)
        
        let completion = AbstractLLM.TextCompletion(
            prefix: try prompt.prefix.promptLiteral,
            text: responseBody.response
        )
        
        return completion
    }
        
    public func completion(
        for prompt: AbstractLLM.ChatPrompt
    ) throws -> AbstractLLM.ChatCompletionStream {
        AbstractLLM.ChatCompletionStream {
            try await self._completion(for: prompt)
        }
    }
    
    private func _completion(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error> {
        let model = try await _model(for: prompt)
        // let modelInfo = try await info(for: model.id)
        
        let requestBody = Ollama.APISpecification.RequestBodies.GenerateChatCompletion(
            model: model.id,
            messages: try prompt.messages.map {
               try Ollama.ChatMessage(from: $0)
            },
            stream: true
        )
        
        let request: HTTPRequest = try Ollama._Endpoint
            .chat(data: requestBody)
            .asURLRequest()
        
        let sessionConfiguration = URLSessionConfiguration.default
                
        sessionConfiguration.timeoutIntervalForRequest = TimeInterval(INT_MAX)
        sessionConfiguration.timeoutIntervalForResource = TimeInterval(INT_MAX)
        sessionConfiguration.httpAdditionalHeaders ??= [:]
        sessionConfiguration.httpAdditionalHeaders!["Accept"] = "text/event-stream"
        sessionConfiguration.httpAdditionalHeaders!["Cache-Control"] = "no-cache"

        let session = URLSession(configuration: sessionConfiguration)
        
        let result = AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error> { (continuation: AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>.Continuation) in
            let task = Task<Void, Swift.Error> {
                let (bytes, response) = try await session.bytes(for: URLRequest(request))
                
                _ = response
                
                var isDone: Bool = false
                
                for try await line in bytes.lines {
                    let data = try line.data(using: .utf8).unwrap()
                    let response = try self.decoder.decode(Ollama.APISpecification.ResponseBodies.GenerateChatCompletion.self, from: data)
                                        
                    if let message = response.message {
                        let completion = try AbstractLLM.ChatCompletion.Partial(delta: message)
                        
                        continuation.yield(.completion(completion))
                    }
                    
                    if response.done {
                        continuation.yield(.stop)
                    }
                }
                
                if !isDone {
                    isDone = true
                }
            }
            ._expectNoThrow()
            
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
        
        return result
    }
    
    func _model(
        for prompt: AbstractLLM.ChatPrompt
    ) async throws -> Ollama.Model {
        let identifier: ModelIdentifier = try prompt.context.get(\.modelIdentifier).unwrap()._oneValue
        
        return try await models.unwrap().firstAndOnly(where: { try $0.__conversion() == identifier }).unwrap()
    }
    
    func _model(
        for prompt: AbstractLLM.TextPrompt
    ) async throws -> Ollama.Model {
        let identifier: ModelIdentifier = try prompt.context.get(\.modelIdentifier).unwrap()._oneValue
        
        return try await models.unwrap().firstAndOnly(where: { try $0.__conversion() == identifier }).unwrap()
    }
}
