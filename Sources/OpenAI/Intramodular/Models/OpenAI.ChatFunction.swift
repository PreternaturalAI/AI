//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Diagnostics
import Swift

extension OpenAI {
    public typealias ChatFunction =  __OpenAI_ChatFunction
    public typealias ChatFunctionResult =  __OpenAI_ChatFunctionResult
}

public protocol __OpenAI_ChatFunctionResult: Codable, Hashable, Sendable {
    
}

public protocol __OpenAI_ChatFunction: Initiable {
    associatedtype Result: Codable & Hashable
    
    var name: String { get }
    
    init()
    
    func perform() throws -> Result
}

/*struct AppIntentFunctionAdapter<Function: AppIntent, Result: Codable>: _AbstractLLM_ChatFunctionProviding {
    @Dependency(\.appRepresentationResolver) var appRepresentationResolver
    
    let intent: Function.Type
    let body: (Function) async throws -> Result
    
    func _evaluate(
        context: _PromptMatterEvaluationContext
    ) async throws -> AbstractLLM.ChatFunction {
        let resolvedType = try $appRepresentationResolver.get().resolve(for: intent)
        let representation = try resolvedType[_NaturalLanguageTokenRepresentation.self].unwrap()
        
        guard case .intent(let intentType) = try resolvedType.descriptor else {
            throw Never.Reason.illegal
        }
        
        let name = try representation[.name].unwrap().value
        let description = try representation[.description].unwrap().value
        
        let encoder = SchemaPromptLiteralCoder(configuration: .init(suppportedSchemes: [.jsonSchema]))
        let encoded = try await encoder.encode(resolvedType)
        let schema = try cast(encoded, to: SchemaPromptLiteral.JSONSchema.self).schema
        
        return AbstractLLM.ChatFunction(
            id: Metatype(intent),
            definition: .init(
                name: name,
                context: description,
                parameters: schema
            ),
            body: { call in
                let decoder = JSONDecoder(keyDecodingStrategy: .convertFromSnakeCase)
                
                let _call = try decoder.decode(
                    AnyCodable.self,
                    from: call.arguments.data(using: String.Encoding.utf8).unwrap()
                )
                
                let intent = try _PromptDataDecoder().decode(
                    intent,
                    withDescriptor: .intent(intentType),
                    from: _call
                )
                
                let result = try await body(intent)
                let _result = try JSON.encode(result).toString(prettyPrint: true, sortKeys: false)
                
                return .init(rawValue: _result)
            }
        )
    }
}

extension PromptMatter {
    public func function<Intent: AppIntent, Result: Codable>(
        _ intent: Intent.Type,
        _ body: @escaping (Intent) async throws -> Result
    ) -> some PromptMatter {
        functions([AppIntentFunctionAdapter(intent: intent, body: body)])
    }
    
    @_disfavoredOverload
    public func function<Intent: AppIntent>(
        _ intent: Intent.Type,
        _ body: @escaping (Intent) async throws -> Void
    ) -> some PromptMatter {
        function(intent) { (intent) -> String in
            try await body(intent)
            
            return "200 OK"
        }
    }
}
I*/
