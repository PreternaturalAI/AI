//
// Copyright (c) Vatsal Manot
//

import CoreMI
import CorePersistence
import Diagnostics
@_spi(Internal) import LargeLanguageModels
import Merge
import Swallow

extension TogetherAI.Client: _TaskDependenciesExporting {
    public var _exportedTaskDependencies: TaskDependencies {
        var result = TaskDependencies()
        
        result[\.llm] = self
        //result[\.embedding] = self
        
        return result
    }
}

extension TogetherAI.Client: LLMRequestHandling {
    private var _debugPrintCompletions: Bool {
        false
    }
    
    public var _availableModels: [ModelIdentifier]? {
        return TogetherAI.Model.allCases.map({ $0.__conversion() })
    }
    
    public func complete<Prompt: AbstractLLM.Prompt>(
        prompt: Prompt,
        parameters: Prompt.CompletionParameters
    ) async throws -> Prompt.Completion {
        let _completion: Any
        
        switch prompt {
            case let prompt as AbstractLLM.TextPrompt:
                _completion = try await _complete(
                    prompt: prompt,
                    parameters: try cast(parameters)
                )
            default:
                throw LLMRequestHandlingError.unsupportedPromptType(Prompt.self)
        }
        
        return try cast(_completion)
    }
    
    private func _complete(
        prompt: AbstractLLM.TextPrompt,
        parameters: AbstractLLM.TextCompletionParameters
    ) async throws -> AbstractLLM.TextCompletion {
        let parameters = try cast(parameters, to: AbstractLLM.TextCompletionParameters.self)
        
        let model = TogetherAI.Model.Completion.mixtral8x7b
        
        let promptText = try prompt.prefix.promptLiteral
        let completion = try await
        self.createCompletion(
            for: model,
            prompt: promptText._stripToText(),
            maxTokens: parameters.tokenLimit.fixedValue,
            stop: parameters.stops,
            temperature: parameters.temperatureOrTopP?.temperature,
            topP: parameters.temperatureOrTopP?.topProbabilityMass
        )
        
        let text = try completion.choices.toCollectionOfOne().first.text
        
        _debugPrint(
            prompt: prompt.debugDescription
                .delimited(by: .quotationMark)
                .delimited(by: "\n")
            ,
            completion: text
                .delimited(by: .quotationMark)
                .delimited(by: "\n")
        )
        
        
        return .init(prefix: promptText, text: text)
    }
}

extension TogetherAI.Client {
    private func _debugPrint(prompt: String, completion: String) {
        guard _debugPrintCompletions else {
            return
        }
        
        guard _isDebugAssertConfiguration else {
            return
        }
        
        let description = String.concatenate(separator: "\n") {
            "=== [PROMPT START] ==="
            prompt.debugDescription
                .delimited(by: .quotationMark)
                .delimited(by: "\n")
            "==== [COMPLETION] ===="
            completion
                .delimited(by: .quotationMark)
                .delimited(by: "\n")
            "==== [PROMPT END] ===="
        }
        
        print(description)
    }
}

// MARK: - Auxiliary

extension ModelIdentifier {
    
    public init(
        from model: TogetherAI.Model.Completion
    ) {
        self.init(provider: .togetherAI, name: model.rawValue, revision: nil)
    }
    
    public init(
        from model: TogetherAI.Model.Embedding
    ) {
        self.init(provider: .togetherAI, name: model.rawValue, revision: nil)
    }
}
