//
// Copyright (c) Vatsal Manot
//

import Diagnostics
import Swallow

@_spi(Internal)
extension LLMRequestHandling {
    public func _completeAllowingEarlyExit(
        prompt: any AbstractLLM.Prompt,
        completionConfiguration: any AbstractLLM._AnyPromptCompletionConfigurationType,
        functions: [AbstractLLM.ChatFunction],
        shouldExitEarly: () async -> Bool
    ) async throws -> AbstractLLM.ChatOrTextCompletion {
        let completion: AbstractLLM.ChatOrTextCompletion
        
        switch prompt {
            case let prompt as AbstractLLM.TextPrompt:
                assert(functions.isEmpty)
                
                completion = try await complete(
                    prompt: .text(prompt),
                    parameters: AbstractLLM.TextCompletionParameters(
                        tokenLimit: .max,
                        temperatureOrTopP: completionConfiguration.temperatureOrTopP,
                        stops: completionConfiguration.stops
                    )
                )
            case let prompt as AbstractLLM.ChatPrompt:
                completion = try await .chat(
                    _completeAllowingEarlyExit(
                        prompt: prompt,
                        parameters: AbstractLLM.ChatCompletionParameters(
                            tokenLimit: .max,
                            temperatureOrTopP: completionConfiguration.temperatureOrTopP,
                            stops: completionConfiguration.stops,
                            functions: functions.map({ $0.definition })
                        ),
                        functions: functions,
                        shouldExitEarly: shouldExitEarly
                    )
                )
            default:
                throw Never.Reason.unsupported
        }
        
        return completion
    }

    public func _completeAllowingEarlyExit(
        prompt: AbstractLLM.ChatPrompt,
        parameters: AbstractLLM.ChatCompletionParameters,
        functions: [AbstractLLM.ChatFunction],
        shouldExitEarly: () async -> Bool
    ) async throws -> AbstractLLM.ChatCompletion {
        let completion = try await complete(
            prompt: prompt,
            parameters: parameters
        )
        
        let lastMessage = try completion.message.content._degenerate()
        
        if lastMessage.components.contains(where: { $0.payload.type == .functionCall }) {
            guard case let .functionCall(call) = try lastMessage.components.toCollectionOfOne().value.payload else {
                throw Never.Reason.unexpected
            }
            
            let function: AbstractLLM.ChatFunction = try functions
                .firstAndOnly(where: { (function) in
                    function.definition.name == call.name.rawValue
                })
                .unwrap()
            
            let result = try await function.body(call)
            
            if await shouldExitEarly() {
                return completion
            }
            
            let invocation = AbstractLLM.ChatFunctionInvocation(
                name: function.definition.name,
                result: result
            )
            
            let functionInvocationMessage = AbstractLLM.ChatMessage(
                role: .other(.function),
                content: try PromptLiteral(functionInvocation: invocation, role: .chat(.other(.function)))
            )
            
            var newPrompt = prompt
            
            newPrompt.messages.append(contentsOf: [completion.message, functionInvocationMessage])
            
            let newCompletion = try await complete(
                prompt: newPrompt,
                parameters: parameters
            )
            
            try _tryAssert {
                try !newCompletion.message.content._degenerate().components.contains {
                    $0.payload.type == .functionCall
                }
            }
            
            return newCompletion
        } else {
            return completion
        }
    }
}
