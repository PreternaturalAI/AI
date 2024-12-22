//
// Copyright (c) Vatsal Manot
//

import CorePersistence
import Swift

extension CoreMI {
    public struct _ServiceVendorIdentifier: Codable, Hashable, RawRepresentable, Sendable {
        public let rawValue: HadeanIdentifier
        
        public init(rawValue: HadeanIdentifier) {
            self.rawValue = rawValue
        }
    }
    
    public protocol _ServiceVendorIdentifierConvertible {
        func __conversion() throws -> CoreMI._ServiceVendorIdentifier
    }
}

extension CoreMI._ServiceVendorIdentifier: PersistentIdentifier {
    public var body: some IdentityRepresentation {
        rawValue
    }
}

extension CoreMI._ServiceVendorIdentifier {
    public static let _Anthropic = CoreMI._ServiceVendorIdentifier(rawValue: "puhif-pudav-gujir-nubup")
    public static let _Cohere = CoreMI._ServiceVendorIdentifier(rawValue: "guzob-fipin-navij-duvon")
    public static let _ElevenLabs = CoreMI._ServiceVendorIdentifier(rawValue: "jatap-jogaz-ritiz-vibok")
    public static let _Fal = CoreMI._ServiceVendorIdentifier(rawValue: "povar-firul-milij-jopat")
    public static let _Groq = CoreMI._ServiceVendorIdentifier(rawValue: "jabub-potuv-juniv-nodik")
    public static let _HuggingFace = CoreMI._ServiceVendorIdentifier(rawValue: "jutot-gugal-luzoh-vorig")
    public static let _HumeAI = CoreMI._ServiceVendorIdentifier(rawValue: "kinot-tugug-rojum-sinis")
    public static let _Mistral = CoreMI._ServiceVendorIdentifier(rawValue: "vogas-fohig-mokij-titun")
    public static let _NeetsAI = CoreMI._ServiceVendorIdentifier(rawValue: "tabut-fozak-tajah-bagaj")
    public static let _Ollama = CoreMI._ServiceVendorIdentifier(rawValue: "sotap-boris-navam-mitoh")
    public static let _OpenAI = CoreMI._ServiceVendorIdentifier(rawValue: "vodih-vakam-hiduz-tosob")
    public static let _Perplexity = CoreMI._ServiceVendorIdentifier(rawValue: "dohug-muboz-bopuz-kasar")
    public static let _PlayHT = CoreMI._ServiceVendorIdentifier(rawValue: "foluv-jufuk-zuhok-hofid")
    public static let _Replicate = CoreMI._ServiceVendorIdentifier(rawValue: "dovon-vatig-posov-luvis")
    public static let _Rime = CoreMI._ServiceVendorIdentifier(rawValue: "tohaz-zivir-bosov-minog")
    public static let _Jina = CoreMI._ServiceVendorIdentifier(rawValue: "bozud-sipup-natin-bizif")
    public static let _TogetherAI = CoreMI._ServiceVendorIdentifier(rawValue: "pafob-vopoj-lurig-zilur")
    public static let _VoyageAI = CoreMI._ServiceVendorIdentifier(rawValue: "hajat-fufoh-janaf-disam")
    public static let _xAI = CoreMI._ServiceVendorIdentifier(rawValue: "niluj-futol-guhaj-pabas")
}

// MARK: - Deprecated

@available(*, deprecated)
public typealias _MIServiceTypeIdentifier = CoreMI._ServiceVendorIdentifier
@available(*, deprecated)
public typealias _MIServiceTypeIdentifierConvertible = CoreMI._ServiceVendorIdentifierConvertible
