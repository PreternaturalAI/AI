//
// Copyright (c) Vatsal Manot
//

import Foundation
import Merge
import Swallow

public protocol __AbstractLLM_ChatCompletionStreamProtocol: ObservableObject, Publisher where Self.Output == AbstractLLM.ChatCompletionStream.Event, Failure == Error {
    typealias Event = AbstractLLM.ChatCompletionStream.Event
    typealias State = AbstractLLM.ChatCompletionStream.State
    
    /// The partially constructed message.
    var partialMessage: AbstractLLM.ChatMessage? { get }
    
    /// The full message if the stream completed succesfully.
    var fullyStreamedMessage: AbstractLLM.ChatMessage? { get }
    
    var messagePublisher: AnyPublisher<AbstractLLM.ChatMessage, Error> { get }
    var state: State { get }
}

extension AbstractLLM {
    public typealias ChatCompletionStreamProtocol = __AbstractLLM_ChatCompletionStreamProtocol
    
    /// An object that represents a live chat-completion stream from an LLM.
    public final class ChatCompletionStream: __AbstractLLM_ChatCompletionStreamProtocol, ObservableObject {
        private var objectWillChangeRelay: ObjectWillChangePublisherRelay<any ChatCompletionStreamProtocol, ChatCompletionStream>!
        private let base: any ChatCompletionStreamProtocol
        
        public var messagePublisher: AnyPublisher<AbstractLLM.ChatMessage, Error> {
            base.messagePublisher
        }
        
        public var partialMessage: AbstractLLM.ChatMessage? {
            base.partialMessage
        }

        public var fullyStreamedMessage: AbstractLLM.ChatMessage? {
            base.fullyStreamedMessage
        }
        
        public var state: State {
            base.state
        }
        
        public init(base: any ChatCompletionStreamProtocol) {
            self.base = base
            
            self.objectWillChangeRelay = .init(source: base, destination: self)
        }
    }
}

// MARK: - Initializers

extension AbstractLLM.ChatCompletionStream {
    public convenience init(
        _ stream: @escaping () async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
    ) {
        self.init(base: AbstractLLM._AsyncStreamToChatCompletionStreamAdaptor(base: stream))
    }
    
    public convenience init(
        _ publisher: @escaping () async throws -> some Publisher<AbstractLLM.ChatCompletionStream.Event, Error>
    ) {
        self.init(base: AbstractLLM._PublisherChatCompletionStreamAdaptor(base: {
            try await publisher().eraseToAnyPublisher()
        }))
    }
    
    public convenience init(
        completion: @escaping () async throws -> AbstractLLM.ChatCompletion
    ) {
        self.init {
            AsyncThrowingStream.just { () -> Event in
                var completion = AbstractLLM.ChatCompletion.Partial(whole: try await completion())
                
                if completion.stopReason == nil {
                    completion.stopReason = .init()
                }
                
                return Event.completion(completion)
            }
        }
    }
}

// MARK: - Conformances

extension AbstractLLM.ChatCompletionStream: Publisher {
    public func receive<S: Subscriber<Event, Error>>(
        subscriber: S
    ) {
        base.receive(subscriber: subscriber)
    }
}

// MARK: - Auxiliary

extension AbstractLLM.ChatCompletionStream {
    public enum State: Hashable, Sendable {
        case waiting
        case streaming
        case canceled
        case completed
        case failed(AnyError)
        
        public enum _Comparison {
            case finished
            
            public static func == (lhs: State, rhs: _Comparison) -> Bool {
                switch (lhs, rhs) {
                    case (.canceled, .finished):
                        return false
                    case (.completed, .finished):
                        return true
                    case (.failed, .finished):
                        return false
                    default:
                        return false
                }
            }
            
            public static func == (lhs: _Comparison, rhs: State) -> Bool {
                rhs == lhs
            }
        }
    }
    
    public enum Event: Codable, Hashable, Sendable {
        public enum _Comparison {
            case completion
            case stop
            
            public static func == (lhs: Event, rhs: _Comparison) -> Bool {
                switch (lhs, rhs) {
                    case (.completion, .completion):
                        return true
                    case (.stop, .stop):
                        return true
                    default:
                        return false
                }
            }
            
            public static func == (lhs: _Comparison, rhs: Event) -> Bool {
                rhs == lhs
            }
        }
        
        case completion(AbstractLLM.ChatCompletion.Partial)
        case stop
    }
}

// MARK: - Internal

extension AbstractLLM {
    public final class _AsyncStreamToChatCompletionStreamAdaptor: __AbstractLLM_ChatCompletionStreamProtocol {
        private let subject = PassthroughSubject<Event, Swift.Error>()
        private let makeBase: () async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
        
        private var base: AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>?
        
        private let _messageSubject = PassthroughSubject<AbstractLLM.ChatMessage, Error>()
        
        @Published private var _message: AbstractLLM.ChatMessage?
        @Published private var _state: State = .waiting
        
        var currentMessage: AbstractLLM.ChatMessage.Partial?
        var stopReason: AbstractLLM.ChatCompletion.StopReason?
        
        public var partialMessage: AbstractLLM.ChatMessage? {
            return _message
        }

        public var fullyStreamedMessage: AbstractLLM.ChatMessage? {
            guard _state == .finished else {
                return nil
            }
            
            return _message
        }
        
        public var messagePublisher: AnyPublisher<AbstractLLM.ChatMessage, Error> {
            _messageSubject
                .onSubscribe { [weak self] in
                    self?._start()
                }
                .eraseToAnyPublisher()
        }
        
        public var state: State {
            _state
        }
        
        public init(
            base: @escaping () async throws -> AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
        ) {
            self.makeBase = base
        }
        
        private func _start() {
            Task.detached(priority: .high) {
                guard self.base == nil else {
                    return
                }
                
                let stream = try await self.makeBase()
                
                self.base = stream
                
                try await self._subscribeAndRelay(to: stream)
            }
            ._expectNoThrow()
        }
        
        @discardableResult
        private func _subscribeAndRelay(
            to base: AsyncThrowingStream<AbstractLLM.ChatCompletionStream.Event, Error>
        ) async throws -> Bool {
            _state = .streaming
            
            do {
                for try await event in base {
                    try await _receive(event: event)
                }
                
                if stopReason == nil {
                    _setCompleted()
                    
                    subject.send(.stop)
                }
            } catch {
                _state = .failed(AnyError(erasing: error))
            }
            
            return true
        }
        
        func _setCompleted() {
            guard _state != .completed else {
                return
            }
            
            subject.send(.stop)
            subject.send(completion: .finished)
            
            _state = .completed
        }
        
        @MainActor
        private func _receive(
            event: AbstractLLM.ChatCompletionStream.Event
        ) throws {
            switch event {
                case .completion(let completion):
                    if let partial = try AbstractLLM.ChatMessage.Partial.coalesce([currentMessage, completion.message]) {
                        var message = try AbstractLLM.ChatMessage(from: partial)
                        
                        if message.id == nil {
                            message.id = .init(erasing: UUID())
                        }
                        
                        self._message = message
                        
                        currentMessage = AbstractLLM.ChatMessage.Partial(whole: message)
                        
                        _messageSubject.send(message)
                    } else {
                        assert(self._message == nil && completion.message == nil)
                    }
                    
                    stopReason = completion.stopReason
                    
                    subject.send(event)
                    
                    if stopReason != nil {
                        _setCompleted()
                    }
                case .stop:
                    _setCompleted()
            }
        }
        
        public func receive<S: Subscriber<Event, Error>>(
            subscriber: S
        ) {
            guard base == nil else {
                assertionFailure()
                
                return
            }
            
            subject
                .prefixUntil(after: { $0 == .stop })
                .receive(subscriber: subscriber)
            
            _start()
        }
    }
    
    public final class _PublisherChatCompletionStreamAdaptor: __AbstractLLM_ChatCompletionStreamProtocol {
        private let cancellables = Cancellables()
        private let subject = PassthroughSubject<Event, Swift.Error>()
        private let makeBase: () async throws -> AnyPublisher<AbstractLLM.ChatCompletionStream.Event, Error>
        
        private var base: AnyPublisher<AbstractLLM.ChatCompletionStream.Event, Error>?
        
        private let _messageSubject = PassthroughSubject<AbstractLLM.ChatMessage, Error>()
        
        @Published private var _message: AbstractLLM.ChatMessage?
        @Published private var _state: State = .waiting
        
        var currentMessage: AbstractLLM.ChatMessage.Partial?
        var stopReason: AbstractLLM.ChatCompletion.StopReason?
        
        public var partialMessage: AbstractLLM.ChatMessage? {
            _message
        }

        public var fullyStreamedMessage: AbstractLLM.ChatMessage? {
            guard _state == .finished else {
                return nil
            }
            
            return _message
        }
                
        public var messagePublisher: AnyPublisher<AbstractLLM.ChatMessage, Error> {
            _messageSubject
                .onSubscribe { [weak self] in
                    self?._start()
                }
                .eraseToAnyPublisher()
        }
        
        public var state: State {
            _state
        }
        
        public init(
            base: @escaping () async throws -> AnyPublisher<AbstractLLM.ChatCompletionStream.Event, Error>
        ) {
            self.makeBase = base
        }
        
        public func receive<S: Subscriber<Event, Error>>(
            subscriber: S
        ) {
            guard base == nil else {
                assertionFailure()
                
                return
            }
            
            subject.receive(subscriber: subscriber)
            
            _start()
        }
        
        private func _start() {
            Task(priority: .high) {
                guard self.base == nil else {
                    return
                }
                
                let publisher = try await makeBase()
                
                self.base = publisher
                
                publisher
                    .onSubscribe {
                        self._state = .streaming
                    }
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveCompletion: { completion in
                            self._setCompleted()
                        },
                        receiveValue: { event in
                            self._receive(event: event)
                        }
                    )
                    .store(in: cancellables)
            }
            ._expectNoThrow()
        }
        
        func _setCompleted() {
            guard _state != .completed else {
                return
            }
            
            subject.send(.stop)
            subject.send(completion: .finished)
            
            _state = .completed
        }
        
        private func _receive(
            event: AbstractLLM.ChatCompletionStream.Event
        ) {
            switch event {
                case .completion(let completion):
                    do {
                        if let partial = try AbstractLLM.ChatMessage.Partial.coalesce([currentMessage, completion.message]) {
                            var message = try AbstractLLM.ChatMessage(from: partial)
                            
                            if message.id == nil {
                                message.id = .init(erasing: UUID())
                            }
                            
                            self._message = message
                            
                            currentMessage = AbstractLLM.ChatMessage.Partial(whole: message)
                            
                            _messageSubject.send(message)
                        } else {
                            assert(self._message == nil && completion.message == nil)
                        }
                        
                        stopReason = completion.stopReason
                        
                        subject.send(event)
                    } catch {
                        cancellables.cancel()
                        
                        _setCompleted()
                    }
                case .stop:
                    _setCompleted()
            }
        }
    }
}
