//
// Copyright (c) Vatsal Manot
//

import CoreMI
import Swift

extension _Gemini {
    public struct Model: RawRepresentable, Codable, Hashable, Sendable, CaseIterable {
        public static var allCases: [Model] = [
            .gemini_2_0_flash_exp,
            .gemini_1_5_pro,
            .gemini_1_5_pro_latest,
            .gemini_1_5_flash,
            .gemini_1_5_flash_latest,
            .gemini_1_0_pro
        ]

        public let rawValue: String
        
        public init(rawValue: String) {
            self.rawValue = rawValue
        }
        
        public static let gemini_2_0_flash_exp = Model(rawValue: "gemini-2.0-flash-exp")
        public static let gemini_1_5_pro = Model(rawValue: "gemini-1.5-pro")
        public static let gemini_1_5_pro_latest = Model(rawValue: "gemini-1.5-pro-latest")
        public static let gemini_1_5_flash = Model(rawValue: "gemini-1.5-flash")
        public static let gemini_1_5_flash_latest = Model(rawValue: "gemini-1.5-flash-latest")
        public static let gemini_1_0_pro = Model(rawValue: "gemini-1.0-pro")
        
        public var maximumContextLength: Int {
            switch self {
                case .gemini_2_0_flash_exp:
                    return 1048576
                case .gemini_1_5_pro, .gemini_1_5_pro_latest:
                    return 1048576
                case .gemini_1_5_flash, .gemini_1_5_flash_latest:
                    return 1048576
                case .gemini_1_0_pro:
                    return 30720
                default:
                    return 30720
            }
        }
        
        public static func tunedModel(_ name: String) -> Model {
            Model(rawValue: name)
        }
    }
}

// MARK: - Conformances

extension _Gemini.Model: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}

extension _Gemini.Model: ModelIdentifierRepresentable {
    private enum _DecodingError: Error {
        case invalidModelProvider
    }
    
    public init(from model: ModelIdentifier) throws {
        guard model.provider == .gemini else {
            throw _DecodingError.invalidModelProvider
        }
        
        self = Self(rawValue: model.name)
    }
    
    public func __conversion() -> ModelIdentifier {
        ModelIdentifier(
            provider: .gemini,
            name: rawValue,
            revision: nil
        )
    }
}
