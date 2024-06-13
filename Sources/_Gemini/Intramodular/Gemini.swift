//
// Copyright (c) Vatsal Manot
//

import Swift

public enum Gemini {
    
}

extension Gemini {
    public enum Model: String, CaseIterable, Codable, Hashable, Sendable {
        case gemini_1_0_pro = "gemini-1.0-pro"
        case gemini_1_5_pro_latest = "gemini-1.5-pro-latest"
        case gemini_1_5_flash_latest = "gemini-1.5-flash-latest"
        case gemini_pro_vision = "gemini-pro-vision"
        
        public var maximumContextLength: Int? {
            switch self {
                case .gemini_1_0_pro:
                    return 30720
                case .gemini_1_5_pro_latest:
                    return 1048576
                case .gemini_1_5_flash_latest:
                    return 1048576
                case .gemini_pro_vision:
                    return nil
            }
        }
    }
}
