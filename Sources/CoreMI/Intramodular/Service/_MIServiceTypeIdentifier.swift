//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

public struct _MIServiceTypeIdentifier: Codable, Hashable, RawRepresentable, Sendable {
    public let rawValue: HadeanIdentifier
    
    public init(rawValue: HadeanIdentifier) {
        self.rawValue = rawValue
    }
}

public protocol _MIServiceTypeIdentifierConvertible {
    func __conversion() throws -> _MIServiceTypeIdentifier
}

extension _MIServiceTypeIdentifier: PersistentIdentifier {
    public var body: some IdentityRepresentation {
        rawValue
    }
}

extension _MIServiceTypeIdentifier {
    public static let _Anthropic = _MIServiceTypeIdentifier(rawValue: "puhif-pudav-gujir-nubup")
    public static let _HuggingFace = _MIServiceTypeIdentifier(rawValue: "jutot-gugal-luzoh-vorig")
    public static let _Mistral = _MIServiceTypeIdentifier(rawValue: "vogas-fohig-mokij-titun")
    public static let _Groq = _MIServiceTypeIdentifier(rawValue: "jabub-potuv-juniv-nodik")
    public static let _Ollama = _MIServiceTypeIdentifier(rawValue: "sotap-boris-navam-mitoh")
    public static let _OpenAI = _MIServiceTypeIdentifier(rawValue: "vodih-vakam-hiduz-tosob")
    public static let _Perplexity = _MIServiceTypeIdentifier(rawValue: "dohug-muboz-bopuz-kasar")
    public static let _Replicate = _MIServiceTypeIdentifier(rawValue: "dovon-vatig-posov-luvis")
    public static let _ElevenLabs = _MIServiceTypeIdentifier(rawValue: "jatap-jogaz-ritiz-vibok")
}
