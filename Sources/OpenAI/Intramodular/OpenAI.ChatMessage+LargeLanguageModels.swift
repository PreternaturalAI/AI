//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import FoundationX
@_spi(Internal) import LargeLanguageModels

extension OpenAI.ChatMessage: AbstractLLM.ChatMessageConvertible {
    public func __conversion() throws -> AbstractLLM.ChatMessage {
        .init(
            id: .init(rawValue: id),
            role: try role.__conversion(),
            content: try PromptLiteral(from: self)
        )
    }
}

extension OpenAI.ChatMessage: _PromptLiteralEncodingContainer {
    public mutating func encode(
        _ component: PromptLiteral._Degenerate.Component
    ) async throws {
        var content: [OpenAI.ChatMessageBody._Content]
        
        switch self.body {
            case .text(let _content):
                content = [.text(_content)]
            case .content(let _content):
                content = _content
            case .functionCall(_):
                throw Never.Reason.unsupported
            case .functionInvocation(_):
                throw Never.Reason.unsupported
        }
        
        switch component.payload {
            case .string(let string):
                content.append(.text(string))
            case .image(let image):
                let imageURL: Base64DataURL = try await image.toBase64DataURL()
                
                content.append(.imageURL(OpenAI.ChatMessageBody._Content.ImageURL(url: imageURL.url, detail: .auto)))
            case .functionCall:
                throw Never.Reason.unsupported
            case .resultOfFunctionCall:
                throw Never.Reason.unsupported
        }
        
        self = .init(
            id: nil, // FIXME: !!!
            role: role,
            body: .content(content)
        )
    }
}

extension OpenAI.ChatMessage {
    public init(
        from message: AbstractLLM.ChatMessage
    ) async throws {
        let role: OpenAI.ChatRole
        
        switch message.role {
            case .system:
                role = .system
            case .user:
                role = .user
            case .assistant:
                role = .assistant
            case .other(.function):
                role = .function
        }
        
        let _content = try message.content._degenerate()
        
        if _content.components.contains(where: { $0.payload.type == .functionCall || $0.payload.type == .functionInvocation }) {
            switch try _content.components.toCollectionOfOne().value.payload {
                case .functionCall(let call):
                    self.init(
                        id: nil,
                        // FIXME: !!!
                        role: role,
                        body: .functionCall(
                            OpenAI.ChatMessageBody.FunctionCall(
                                name: call.name.rawValue,
                                arguments: try call.arguments.__conversion()
                            )
                        )
                    )
                case .resultOfFunctionCall(let result):
                    self.init(
                        id: nil, // FIXME: !!!
                        role: role,
                        body: .functionInvocation(
                            .init(
                                name: result.name.rawValue,
                                response: try result.result.__conversion() as String
                            )
                        )
                    )
                default:
                    assertionFailure("Unsupported prompt literal.")
                    
                    throw Never.Reason.illegal
            }
        } else {
            var _temp = Self(
                id: nil, // FIXME: !!!
                role: role,
                body: .content([])
            )
            
            try await message.content._encode(to: &_temp)
            
            self = _temp
        }
    }
}

extension AbstractLLM.ChatMessage {
    public init(
        from message: OpenAI.ChatMessage
    ) throws {
        let id = message.id
        let role: AbstractLLM.ChatRole
        
        switch message.role {
            case .system:
                role = .system
            case .user:
                role = .user
            case .assistant:
                role = .assistant
            case .function:
                role = .other(.function)
        }
        
        switch message.body {
            case .text(let content):
                self.init(
                    id: AnyPersistentIdentifier(erasing: id),
                    role: role,
                    content: PromptLiteral(
                        content,
                        role: .chat(role)
                    )
                )
            case .content(let content):
                self.init(
                    id: AnyPersistentIdentifier(erasing: id),
                    role: role,
                    content: PromptLiteral(
                        from: content,
                        role: .chat(role)
                    )
                )
            case .functionCall(let call):
                self.init(
                    id: AnyPersistentIdentifier(erasing: id),
                    role: role,
                    content: try PromptLiteral(
                        functionCall: .init(
                            functionID: nil,
                            name: AbstractLLM.ChatFunction.Name(rawValue: call.name),
                            arguments: AbstractLLM.ChatFunctionCall.Arguments(unencoded: call.arguments),
                            context: .init()
                        ),
                        role: .chat(role)
                    )
                )
            case .functionInvocation(let invocation):
                self.init(
                    id: AnyPersistentIdentifier(erasing: id),
                    role: role,
                    content: try .init(
                        functionInvocation: .init(
                            functionID: nil,
                            name: AbstractLLM.ChatFunction.Name(rawValue: invocation.name),
                            result: .init(rawValue: invocation.response)
                        ),
                        role: .chat(role)
                    )
                )
        }
    }
}

extension PromptLiteral {
    public init(from message: OpenAI.ChatMessage) throws {
        let role: PromptMatterRole
        
        switch message.role {
            case .system:
                role = .chat(.system)
            case .user:
                role = .chat(.user)
            case .assistant:
                role = .chat(.assistant)
            case .function:
                role = .chat(.other(.function))
        }
        
        switch message.body {
            case .text(let text):
                self.init(from: [.text(text)], role: role)
            case .content(let content):
                self.init(from: content, role: role)
            case .functionCall:
                TODO.unimplemented
            case .functionInvocation:
                TODO.unimplemented
        }
    }
    
    init(
        from contents: [OpenAI.ChatMessageBody._Content],
        role: PromptMatterRole
    ) {
        var components: [PromptLiteral.StringInterpolation.Component] = []
        
        for content in contents {
            switch content {
                case .text(let content):
                    components.append(
                        PromptLiteral.StringInterpolation.Component(
                            payload: .stringLiteral(content),
                            role: role
                        )
                    )
                case .imageURL(let image):
                    assert(image.detail == .auto) // FIXME
                    
                    components.append(
                        PromptLiteral.StringInterpolation.Component(
                            payload: .image(.url(image.url)),
                            role: role
                        )
                    )
            }
        }
        
        self.init(stringInterpolation: .init(components: components))
    }
}
