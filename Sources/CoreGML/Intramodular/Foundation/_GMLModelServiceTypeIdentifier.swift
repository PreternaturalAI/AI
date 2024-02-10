//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

public struct _GMLModelServiceTypeIdentifier: Codable, Hashable, RawRepresentable, Sendable {
    public let rawValue: String
    
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

public protocol _GMLModelServiceTypeIdentifierConvertible {
    func __conversion() throws -> _GMLModelServiceTypeIdentifier
}

extension _GMLModelServiceTypeIdentifier: PersistentIdentifier {
    public var body: some IdentityRepresentation {
        rawValue
    }
}

extension _GMLModelServiceTypeIdentifier {
    public static let _Anthropic = _GMLModelServiceTypeIdentifier(rawValue: "puhif-pudav-gujir-nubup")
    public static let _HuggingFace = _GMLModelServiceTypeIdentifier(rawValue: "jutot-gugal-luzoh-vorig")
    public static let _Mistral = _GMLModelServiceTypeIdentifier(rawValue: "vogas-fohig-mokij-titun")
    public static let _Ollama = _GMLModelServiceTypeIdentifier(rawValue: "sotap-boris-navam-mitoh")
    public static let _OpenAI = _GMLModelServiceTypeIdentifier(rawValue: "vodih-vakam-hiduz-tosob")
    public static let _Perplexity = _GMLModelServiceTypeIdentifier(rawValue: "dohug-muboz-bopuz-kasar")
    public static let _Replicate = _GMLModelServiceTypeIdentifier(rawValue: "dovon-vatig-posov-luvis")
}
