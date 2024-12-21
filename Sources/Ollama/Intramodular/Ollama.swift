//
// Copyright (c) Preternatural AI, Inc.
//

import CorePersistence
import FoundationX
import LargeLanguageModels
import Merge
import NetworkKit

public final class Ollama: ObservableObject {
    public static let shared: Ollama = Ollama()
    
    let session = HTTPSession.shared
    
    @UserDefault.Published("models", store: UserDefaults(suiteName: "com.vmanot.Ollama")!)
    private var _cachedModels: [Ollama.Model]?
    
    public var _allKnownModels: [Ollama.Model]? {
        _cachedModels
    }
    
    @MainActor
    public var models: [Ollama.Model]? {
        get async {
            try? await _cachedModels.unwrapOrInitializeInPlace {
                try? await self.listModels()
            }
        }
    }
    
    public init(
        host: URL = URL(string: "http://localhost:11434")!
    ) {
        Ollama._Endpoint._apiSpecification.host = host
                
        Task { @MainActor in
            _ = self._cachedModels = try? await self.listModels()
        }
    }
}

@MainActor
extension Ollama {
    public var isReachable: Bool {
        get async {
            do {
                let request = try Ollama._Endpoint.root.asURLRequest()
                
                _ = try await HTTPSession.shared.data(for: request).validate()
                
                return true
            } catch {
                return false
            }
        }
    }
    
    public func listModels() async throws -> [Ollama.Model] {
        let request = try Ollama._Endpoint.models.asURLRequest()
        
        return try await session
            .data(for: request)
            .decode(Ollama.APISpecification.ResponseBodies.GetModels.self, using: decoder)
            .models
    }
    
    public func info(
        for model: Ollama.Model.ID
    ) async throws -> Ollama.APISpecification.ResponseBodies.GetModelInfo {
        let request = try Ollama._Endpoint.modelInfo(data: .init(name: model)).asURLRequest()
        
        return try await session.data(for: request).decode(Ollama.APISpecification.ResponseBodies.GetModelInfo.self, using: decoder)
    }
}

// MARK: - Conformances

extension Ollama: PersistentlyRepresentableType {
    public static var persistentTypeRepresentation: some IdentityRepresentation {
        CoreMI._ServiceVendorIdentifier._Ollama
    }
}

extension Ollama: CoreMI._ServiceClientProtocol {
    
}

extension CoreMI._ServiceClientProtocol where Self == Ollama {
    public init(
        account: (any CoreMI._ServiceAccountProtocol)?
    ) async throws {
        let account: any CoreMI._ServiceAccountProtocol = try account.unwrap()
        let serviceVendorIdentifier: CoreMI._ServiceVendorIdentifier = try account.serviceVendorIdentifier.unwrap()
        
        guard serviceVendorIdentifier == CoreMI._ServiceVendorIdentifier._Ollama else {
            throw CoreMI._ServiceClientError.incompatibleVendor(serviceVendorIdentifier)
        }
        
        self = .shared
    }
}

// MARK: - Auxiliary

extension Ollama {
    var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom { decoder -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            formatter.formatOptions = [.withInternetDateTime]
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Cannot decode date string \(dateString)")
        }
        
        return decoder
    }
}
