//
// Copyright (c) Vatsal Manot
//

import CorePersistence
@_spi(Internal) import LargeLanguageModels

extension Anthropic.ChatMessage: _PromptLiteralEncodingContainer {
    public mutating func encode(
        _ component: PromptLiteral._Degenerate.Component
    ) async throws {
        var content: [Anthropic.ChatMessage.Content.ContentObject] = Array(self.content)
        
        switch component.payload {
            case .string(let string):
                content.append(.text(string))
            case .image(let image):
                let image = try Anthropic.ChatMessage.Content.ImageSource(url: try await image.toBase64DataURL())
                
                content.append(.image(image))
            case .functionCall(let call):
                content.append(
                    .toolUse(
                        Anthropic.ChatMessage.Content.ToolUse(
                            id: try call.functionID.unwrap().as(String.self),
                            name: call.name.rawValue,
                            input: try call.arguments.__conversion()
                        )
                    )
                )
            case .resultOfFunctionCall(let result):
                content.append(
                    .toolResult(
                        Anthropic.ChatMessage.Content.ToolResult(
                            toolUseID: try result.functionID.unwrap().as(String.self),
                            content: try result.result.__conversion()
                        )
                    )
                )
        }
        
        self = try .init(
            id: nil, // FIXME: !!!
            role: role,
            content: content
        )
    }
}

extension Anthropic.ChatMessage {
    public init(
        from message: AbstractLLM.ChatMessage
    ) async throws {
        let role: Anthropic.ChatMessage.Role
        
        switch message.role {
            case .system:
                throw Never.Reason.illegal
            case .user:
                role = .user
            case .assistant:
                role = .assistant
            case .other(let other):
                switch other {
                    case .function:
                        role = .user
                }
        }
        
        var _temp = try Self(
            id: self.id,
            role: role,
            content: .list([])
        )
        
        try await message.content._encode(to: &_temp)
        
        self = _temp
    }
}

extension AbstractLLM.ChatMessage {
    public init(
        from message: Anthropic.ChatMessage
    ) throws {
        let id = message.id
        let role: AbstractLLM.ChatRole
        
        switch message.role {
            case .user:
                role = .user
            case .assistant:
                role = .assistant
        }
        
        switch message.content {
            case .text(let content):
                self.init(
                    id: AnyPersistentIdentifier(erasing: id),
                    role: role,
                    content: PromptLiteral(
                        content,
                        role: .chat(role)
                    )
                )
            case .list(let content):
                self.init(
                    id: AnyPersistentIdentifier(erasing: id),
                    role: role,
                    content: try PromptLiteral(
                        from: content,
                        role: .chat(role)
                    )
                )
        }
    }
}

extension PromptLiteral {
    public init(from message: Anthropic.ChatMessage) throws {
        let role: PromptMatterRole
        
        switch message.role {
            case .user:
                role = .chat(.user)
            case .assistant:
                role = .chat(.assistant)
        }
        
        switch message.content {
            case .text(let text):
                try self.init(from: [.text(text)], role: role)
            case .list(let content):
                try self.init(from: content, role: role)
        }
    }
    
    init(
        from contents: [Anthropic.ChatMessage.Content.ContentObject],
        role: PromptMatterRole
    ) throws {
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
                case .image(let image):
                    components.append(
                        PromptLiteral.StringInterpolation.Component(
                            payload: try StringInterpolation.Component.Payload(from: image),
                            role: role
                        )
                    )
                case .toolUse:
                    TODO.unimplemented
                case .toolResult:
                    TODO.unimplemented
            }
        }
        
        self.init(stringInterpolation: .init(components: components))
    }
}

extension PromptLiteral.StringInterpolation.Component.Payload {
    public init(from image: Anthropic.ChatMessage.Content.ContentObject.ImageSource) throws {
        TODO.unimplemented
    }
}
