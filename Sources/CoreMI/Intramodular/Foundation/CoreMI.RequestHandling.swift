//
// Copyright (c) Vatsal Manot
//

import Foundation

extension CoreMI {
    /// A type that handles generative machine learning requests.
    public protocol RequestHandling {
        /// The list of available models.
        ///
        /// `nil` if unknown.
        var _availableModels: [ModelIdentifier]? { get }
        
        func consider<R: CoreMI.Request>(_ request: R) async throws -> CoreMI.RequestConsideration
        
        func perform<Request: CoreMI.Request, Result: CoreMI.RequestResult>(
            _ request: Request,
            returning resultType: Result.Type
        ) async throws -> Result
    }
}

extension CoreMI.RequestHandling {
    public var _availableModels: [ModelIdentifier]? {
        nil
    }
    
    public func consider<R: CoreMI.Request>(
        _ request: R
    ) -> CoreMI.RequestConsideration {
        CoreMI.RequestConsideration()
    }
    
    public func perform<Request: CoreMI.Request, Result: CoreMI.RequestResult>(
        _ request: Request,
        returning resultType: Result.Type
    ) async throws -> Result {
        fatalError()
    }
}

extension CoreMI {
    public struct RequestConsideration {
        
    }
}

extension CoreMI {
    public protocol RequestHandlerAttributeKey {
        
    }
}

extension CoreMI {
    public enum ConceptualSchema {
        public protocol MultimodalModelCapability {
            
        }
    }
}

extension CoreMI.ConceptualSchema {
    public enum ModelCapabilities: _StaticSwift.Namespace {
        
    }
}

extension CoreMI.ConceptualSchema.ModelCapabilities {
    public struct FunctionCalling: CoreMI.ConceptualSchema.MultimodalModelCapability {
        
    }
    
    public struct Vision: CoreMI.ConceptualSchema.MultimodalModelCapability {
        
    }
}
