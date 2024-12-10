//
// Copyright (c) Vatsal Manot
//

import NetworkKit
import Swallow

extension OpenAI {
    public final class AssistantSession: ObservableObject {
        private let taskQueue = ThrowingTaskQueue()
        
        public let client: OpenAI.Client
        public let assistantID: String
        
        @MainActor
        @Published private(set) var _thread: OpenAI.Thread?
        @MainActor
        @Published private(set) var _latestThreadRun: OpenAI.Run?
        
        @MainActor
        @Published public private(set) var messages: [OpenAI.Message]
        @MainActor
        @Published public private(set) var tools: [OpenAI.Tool]
        
        @MainActor
        public var thread: OpenAI.Thread {
            get async throws {
                if let _thread {
                    return _thread
                } else {
                    return try await taskQueue.perform {
                        try await _createThread(messages: [])
                    }
                }
            }
        }
        
        @MainActor
        public init(
            client: OpenAI.Client,
            assistantID: String,
            tools: [OpenAI.Tool]
        ) {
            self.client = client
            self.assistantID = assistantID
            self.messages = []
            self.tools = tools
            
            taskQueue.addTask {
                try await self._fetchAllMessages()
            }
        }
    }
}

extension OpenAI.AssistantSession {
    public func send(
        _ message: OpenAI.ChatMessage
    ) async throws {
        try await self.taskQueue.perform {
            try await self._createMessageAndSend(message)
        }
    }
    
    public func send(
        _ message: String
    ) async throws {
        try await self.send(OpenAI.ChatMessage(role: .user, body: message))
    }
    
    public func run() async throws {
        try await self.taskQueue.perform {
            try await _runThread()
            try await _waitForLatestRunToComplete()
        }
    }
    
    public func update() async throws {
        try await self._fetchAllMessages()
    }
}

// MARK: - Internal

@MainActor
extension OpenAI.AssistantSession {
    private func _createThread(
        messages: [OpenAI.ChatMessage]
    ) async throws -> OpenAI.Thread {
        assert(messages.isEmpty)
        
        let thread = try await client.run(\.createThread, with: .init(messages: messages, metadata: [:]))
        
        self._thread = thread
        
        return thread
    }
    
    @MainActor
    private func _createMessageAndSend(
        _ message: OpenAI.ChatMessage
    ) async throws {
        if _thread != nil && messages.isEmpty {
            try await _fetchAllMessages()
        }
        
        let thread = try await self.thread
        let message = try await client.run(\.createMessageForThread, with: (thread: thread.id, requestBody: .init(from: message)))
        
        self.messages.append(message)
    }
    
    private func _fetchAllMessages() async throws {
        guard _thread != nil else {
            return
        }
        
        let thread = try await self.thread
        
        let listMessagesResponse = try await _performRetryingTask {
            try await self.client.run(
                \.listMessagesForThread,
                 with: thread.id
            )
        }
        
        assert(listMessagesResponse.hasMore == false)
        
        self.messages = listMessagesResponse.data.sorted(by: { $0.createdAt < $1.createdAt })
    }
    
    
    @discardableResult
    private func _runThread() async throws -> OpenAI.Run {
        if let existingRun = self._latestThreadRun {
            try await _refreshLatestRun()
            
            assert(existingRun.status.isTerminal)
            
            self._latestThreadRun = nil
        }
        
        let thread = try await thread
        
        if let run = _latestThreadRun {
            assert(run.threadID == thread.id)
            
            return run
        } else {
            let run = try await client.createRun(
                threadID: thread.id,
                assistantID: assistantID,
                model: nil,
                instructions: nil,
                tools: [.retrieval]
            )
            
            self._latestThreadRun = run
            
            return run
        }
    }
    
    private func _waitForLatestRunToComplete(
        timeout: DispatchTimeInterval = .seconds(10)
    ) async throws {
        guard _latestThreadRun != nil else {
            assertionFailure()
            
            return
        }
        
        try await withTaskTimeout(timeout) { @MainActor in
            while true {
                try Task.checkCancellation()
                
                let run = try await _refreshLatestRun()
                
                if run.status.isTerminal {
                    try await self._fetchAllMessages()
                    
                    return
                }
                
                try await Task.sleep(.seconds(1))
            }
        }
    }
    
    @discardableResult
    private func _refreshLatestRun() async throws -> OpenAI.Run {
        let existingRun = try _latestThreadRun.unwrap()
        let thread = try await self.thread
        
        let result = try await _performRetryingTask(retryDelay: .seconds(1)) {
            try await self.client.retrieve(run: existingRun.id, thread: thread.id)
        }
        
        self._latestThreadRun = result
        
        return result
    }
}
