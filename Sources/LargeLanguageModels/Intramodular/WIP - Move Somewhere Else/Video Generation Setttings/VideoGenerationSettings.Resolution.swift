//
// Copyright (c) Preternatural AI, Inc.
//

import Foundation

extension VideoGenerationSettings {
    public enum Resolution: Codable, Hashable {
        // Square Resolutions
        case sd512x512
        case sd768x768
        case sd1024x1024
        
        // Landscape HD Resolutions
        case hd720p      // 1280x720
        case hd1080p     // 1920x1080
        case hd1440p     // 2560x1440
        case uhd4k       // 3840x2160
        
        // Social Media Formats
        case instagram   // 1080x1080
        case story      // 1080x1920
        case tiktok     // 1080x1920
        case youtube    // 1920x1080
        
        // Custom Resolution
        case custom(width: Int, height: Int)
        
        public static var allCases: [Resolution] {
            [
                .sd512x512, .sd768x768, .sd1024x1024,
                .hd720p, .hd1080p, .hd1440p, .uhd4k,
                .instagram, .story, .tiktok, .youtube
            ]
        }
        
        public var dimensions: (width: Int, height: Int) {
            switch self {
                // Square Resolutions
                case .sd512x512:
                    return (512, 512)
                case .sd768x768:
                    return (768, 768)
                case .sd1024x1024:
                    return (1024, 1024)
                
                // Landscape HD Resolutions
                case .hd720p:
                    return (1280, 720)
                case .hd1080p:
                    return (1920, 1080)
                case .hd1440p:
                    return (2560, 1440)
                case .uhd4k:
                    return (3840, 2160)
                
                // Social Media Formats
                case .instagram:
                    return (1080, 1080)
                case .story:
                    return (1080, 1920)
                case .tiktok:
                    return (1080, 1920)
                case .youtube:
                    return (1920, 1080)
                
                case .custom(let width, let height):
                    return (width, height)
            }
        }
        
        public var width: Int { dimensions.width }
        public var height: Int { dimensions.height }
        
        public var aspectRatio: String {
            let gcd = calculateGCD(width, height)
            let simplifiedWidth = width / gcd
            let simplifiedHeight = height / gcd
            
            // Check for common aspect ratios
            switch (simplifiedWidth, simplifiedHeight) {
                case (1, 1): return "1:1"    // Square
                case (16, 9): return "16:9"  // Standard Widescreen
                case (9, 16): return "9:16"  // Vertical/Portrait
                case (4, 3): return "4:3"    // Traditional TV
                case (21, 9): return "21:9"  // Ultrawide
                default: return "\(simplifiedWidth):\(simplifiedHeight)"
            }
        }
        
        public var resolution: String {
            switch self {
                case .uhd4k:
                    return "4K"
                case .hd1440p:
                    return "1440p"
                case .hd1080p, .youtube:
                    return "1080p"
                case .hd720p:
                    return "720p"
                case .instagram, .story, .tiktok:
                    return "1080p"
                case .sd512x512:
                    return "512p"
                case .sd768x768:
                    return "768p"
                case .sd1024x1024:
                    return "1024p"
                case .custom(let width, _):
                    if width >= 3840 { return "4K" }
                    if width >= 2560 { return "1440p" }
                    if width >= 1920 { return "1080p" }
                    if width >= 1280 { return "720p" }
                    return "\(width)p"
            }
        }
        
        public static func detectResolution(width: Int, height: Int) -> Resolution {
            switch (width, height) {
                case (512, 512): return .sd512x512
                case (768, 768): return .sd768x768
                case (1024, 1024): return .sd1024x1024
                case (1280, 720): return .hd720p
                case (1920, 1080): return .hd1080p
                case (2560, 1440): return .hd1440p
                case (3840, 2160): return .uhd4k
                case (1080, 1080): return .instagram
                case (1080, 1920): return .story
                default: return .custom(width: width, height: height)
            }
        }
        
        private func calculateGCD(_ a: Int, _ b: Int) -> Int {
            var a = a
            var b = b
            while b != 0 {
                let temp = b
                b = a % b
                a = temp
            }
            
            return a
        }
        
        public var displayName: String {
            switch self {
                case .sd512x512: return "512×512"
                case .sd768x768: return "768×768"
                case .sd1024x1024: return "1024×1024"
                case .hd720p: return "HD 720p"
                case .hd1080p: return "Full HD 1080p"
                case .hd1440p: return "QHD 1440p"
                case .uhd4k: return "4K UHD"
                case .instagram: return "Instagram Square"
                case .story: return "Instagram/TikTok Story"
                case .tiktok: return "TikTok Video"
                case .youtube: return "YouTube HD"
                case .custom(let width, let height):
                    return "\(width)×\(height)"
            }
        }
    }
}
